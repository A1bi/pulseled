require "socket"

module AppleMidi
  BIND         = "::"
  CONTROL_PORT = 5099

  class Server
    def initialize
      @socket = UDPSocket.new(Socket::Family::INET6)
      @socket.bind BIND, CONTROL_PORT
    end

    def listen
      message = Bytes.new(500)
      loop do
        bytes_read, client_addr = @socket.receive(message)
        puts "New MIDI connection from client #{client_addr}."
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
      puts "Created MIDI session with initiator token #{message[8..11].hexstring}."
    end

    private def handle_closing(message)
      puts "Closed MIDI session with initiator token #{message[8..11].hexstring}."
    end
  end
end
