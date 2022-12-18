require "socket"
require "./session"

module AppleMidi
  BIND         = "::"
  CONTROL_PORT = 5099

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
          handle_invitation(message)
        when "BY"
          handle_closing(message)
        end
      end
    end

    def close
      @socket.close
    end

    private def handle_invitation(message)
      session = @sessions.find { |s| s.initiator_token == message[8..11] }
      return unless session.nil?

      session = Session.new(message)
      @sessions << session
      puts "#{session.initiator_token.hexstring}: Created MIDI session with peer \"#{session.peer_name}\"."
    end

    private def handle_closing(message)
      session = @sessions.find { |s| s.sender_ssrc == message[12..15] }
      return if session.nil?

      @sessions.delete(session)
      puts "#{session.initiator_token.hexstring}: Closed MIDI session."
    end
  end
end
