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
            puts "<= #{client_addr}"

            if message[..1] == Bytes[0xff, 0xff] && message[4..7] == Bytes[0x0, 0x0, 0x0, 0x2]
              handle_apple_midi_packet(message, client_addr)
            end
          end
        end
      end
    end

    def close
      @control_socket.close
    end

    private def handle_apple_midi_packet(message, client_addr)
      case String.new(message[2..3])
      when "IN"
        handle_invitation(message, client_addr)
      when "BY"
        handle_closing(message)
      end
    end

    private def handle_invitation(message, client_addr)
      session = @sessions.find { |s| s.initiator_token == message[8..11] }

      if session.nil?
        session = Session.new(message)
        @sessions << session
        puts "#{session.initiator_token.hexstring}: Created MIDI session with peer \"#{session.peer_name}\"."
      end

      accept_invitation(session, client_addr)
    end

    private def accept_invitation(session, client_addr)
      io = IO::Memory.new

      io.write_bytes(0xffff.to_u16)
      io.write_string("OK".to_slice)
      io.write_bytes(UInt32.new(2), IO::ByteFormat::NetworkEndian)
      io.write(session.initiator_token)
      io.write(session.ssrc)
      io.write_string(PEER_NAME.to_slice)
      io.write_byte(0)

      respond_to_peer(client_addr, io)
      puts "#{session.initiator_token.hexstring}: Accepted invitation."
    end

    private def handle_closing(message)
      session = @sessions.find { |s| s.peer_ssrc == message[12..15] }
      return if session.nil?

      @sessions.delete(session)
      puts "#{session.initiator_token.hexstring}: Closed MIDI session."
    end

    private def respond_to_peer(addr, message)
      socket = UDPSocket.new(Socket::Family::INET6)
      socket.connect(addr)
      socket.send(message.to_slice)
      puts "=> #{addr}"
    end
  end
end
