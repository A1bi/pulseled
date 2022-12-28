require "./strip_set"

module Led
  class BridgeClient
    DEFAULT_PORT = 29384.to_u16

    def initialize(host : String, port : UInt16 = DEFAULT_PORT)
      @socket = UDPSocket.new(Socket::Family::INET6)
      @socket.connect(host, port)
    end

    def send_frame(set : StripSet)
      io = IO::Memory.new
      io.write_byte(set.bridge_channel)
      io.write_bytes(0.to_u16)

      set.leds.each do |color|
        io.write(color.to_bridge_bytes)
      end

      @socket.send(io.to_slice)
    end

    def close
      @socket.close
    end
  end
end
