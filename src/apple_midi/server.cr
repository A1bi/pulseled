require "socket"
require "./session"

module AppleMidi
  BIND         = "::"
  CONTROL_PORT = 5099
  MIDI_PORT    = CONTROL_PORT + 1
  PEER_NAME    = "pulseled"

  class Server
    def initialize
      @control_socket = UDPSocket.new(Socket::Family::INET6)
      @control_socket.bind BIND, CONTROL_PORT

      @midi_socket = UDPSocket.new(Socket::Family::INET6)
      @midi_socket.bind BIND, MIDI_PORT

      @sessions = [] of Session
    end

    def listen
      [@control_socket, @midi_socket].each do |socket|
        spawn do
          message = Bytes.new(500)
          loop do
            bytes_read, client_addr = socket.receive(message)
            # puts "<= #{client_addr}"

            if message[..1] == Bytes[0xff, 0xff]
              handle_apple_midi_packet(message, client_addr)
            elsif message[1] == 0x61
              handle_rtp_midi_packet(message)
            else
              puts "Unknown packet received. Ignoring."
            end
          end
        end
      end
    end

    def close
      [@control_socket, @midi_socket].each { |s| s.close }
    end

    private def handle_apple_midi_packet(message, client_addr)
      case String.new(message[2..3])
      when "IN"
        handle_invitation(message, client_addr)
      when "CK"
        handle_clock_synchronization(message, client_addr)
      when "BY"
        handle_closing(message)
      end
    end

    private def handle_rtp_midi_packet(message)
      return if (session = find_session(message[8..11])).nil?

      case message[13]
      when 0xfa
        session.reset_clock
      when 0xf8
        puts "QUARTER" if session.pulse_clock
      end

      session.last_sequence_number = message[2..3].dup
    end

    private def handle_invitation(message, client_addr)
      return if message[4..7] != Bytes[0x0, 0x0, 0x0, 0x2]

      if (session = find_session(message[12..15])).nil?
        session = Session.new(message)
        @sessions << session
        puts "#{session.initiator_token.hexstring}: Created MIDI session with peer \"#{session.peer_name}\"."
      end

      accept_invitation(session, client_addr)
      transmit_feedback(session, client_addr)
    end

    private def handle_clock_synchronization(message, client_addr)
      return if (session = find_session(message[4..7])).nil?

      count = message[8].to_u8 + 1
      return if count > 2

      timestamps = Array(Bytes).new(3)
      3.times do |i|
        timestamps << message[12 + 8 * i, 8]
      end

      now = IO::Memory.new
      now.write_bytes(Time.utc.to_unix_ms * 10, IO::ByteFormat::NetworkEndian)
      timestamps[count] = now.to_slice

      response = clock_synchronization_packet(session, count, timestamps)

      respond_to_peer(client_addr, response)
      puts "#{session.initiator_token.hexstring}: Sent clock sync with count = #{count}."
    end

    private def handle_closing(message)
      return if (session = find_session(message[12..15])).nil?

      session.transmit_feedback = false
      @sessions.delete(session)
      puts "#{session.initiator_token.hexstring}: Closed MIDI session."
    end

    private def accept_invitation(session, client_addr)
      io = apple_midi_packet("OK")
      io.write_bytes(UInt32.new(2), IO::ByteFormat::NetworkEndian)
      io.write(session.initiator_token)
      io.write(session.ssrc)
      io.write_string(PEER_NAME.to_slice)
      io.write_byte(0)

      respond_to_peer(client_addr, io)
      puts "#{session.initiator_token.hexstring}: Accepted invitation."
    end

    private def transmit_feedback(session, client_addr)
      return if session.transmit_feedback

      session.transmit_feedback = true

      spawn do
        loop do
          sleep 5.seconds
          break unless session.transmit_feedback

          io = feedback_packet(session)
          respond_to_peer(client_addr, io)
        end
      end
    end

    private def clock_synchronization_packet(session, count, timestamps)
      io = apple_midi_packet("CK")
      io.write(session.ssrc)
      io.write_byte(count)
      io.write(Bytes[0, 0, 0])

      timestamps.each do |timestamp|
        io.write(timestamp)
      end

      io
    end

    private def feedback_packet(session)
      io = apple_midi_packet("RS")
      io.write(session.ssrc)
      io.write(session.last_sequence_number)
      io.write(Bytes[0, 0])
      io
    end

    private def apple_midi_packet(command)
      io = IO::Memory.new
      io.write_bytes(0xffff.to_u16)
      io.write_string(command.to_slice)
      io
    end

    private def respond_to_peer(addr, message)
      socket = UDPSocket.new(Socket::Family::INET6)
      socket.connect(addr)
      socket.send(message.to_slice)
      puts "=> #{addr}"
    end

    private def find_session(peer_ssrc)
      @sessions.find { |s| s.peer_ssrc == peer_ssrc }
    end
  end
end
