require "socket"
require "./session"

module AppleMidi
  BIND         = "::"
  CONTROL_PORT = 5099
  PEER_NAME    = "pulseled"

  class Server
    def initialize
      @socket = UDPSocket.new(Socket::Family::INET6)
      @socket.bind BIND, CONTROL_PORT
      @sessions = [] of Session
    end

    def listen
      message = Bytes.new(500)
      loop do
        bytes_read, client_addr = @socket.receive(message)
        puts "<= #{client_addr}"
        next if message[..1] != Bytes[0xff, 0xff] || message[4..7] != Bytes[0x0, 0x0, 0x0, 0x2]

        case String.new(message[2..3])
        when "IN"
          handle_invitation(message, client_addr)
        when "BY"
          handle_closing(message)
        end
      end
    end

    def close
      @socket.close
    end

    private def handle_invitation(message, client_addr)
      session = @sessions.find { |s| s.initiator_token == message[8..11] }
      return unless session.nil?

      session = Session.new(message, client_addr)
      @sessions << session
      puts "#{session.initiator_token.hexstring}: Created MIDI session with peer \"#{session.peer_name}\"."

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

      session.peer_control_socket.send(io.to_slice)
      puts "#{session.initiator_token.hexstring}: Accepted invitation."
      puts "=> #{client_addr}"
    end

    private def handle_closing(message)
      session = @sessions.find { |s| s.peer_ssrc == message[12..15] }
      return if session.nil?

      session.close
      @sessions.delete(session)
      puts "#{session.initiator_token.hexstring}: Closed MIDI session."
    end
  end
end
