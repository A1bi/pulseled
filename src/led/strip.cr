require "./color"

module Led
  class Strip
    getter leds : Array(Color)

    def initialize(led_count : UInt16)
      @leds = typeof(@leds).new(led_count, Color.black)
    end
  end
end
