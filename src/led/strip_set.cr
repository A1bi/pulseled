require "./strip"
require "./bridge_client"

module Led
  class StripSet
    property strips
    property bridge_client : BridgeClient?
    property bridge_channel : UInt8 = 0

    def initialize(@strips = [] of Led::Strip)
    end

    def leds
      strips.map(&.leds).flatten
    end

    def send_frame_to_bridge
      unless (client = @bridge_client).nil?
        client.send_frame(self)
      end
    end
  end
end
