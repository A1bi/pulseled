require "./color"

module Led
  class Strip
    getter leds : Array(Color)

    def initialize(led_count : UInt16)
      @leds = typeof(@leds).new(led_count, Color.black)
    end

    def size
      @leds.size
    end

    def copy_from(strip : Strip)
      count = [size, strip.size].min
      leds[...count] = strip.leds[...count]
      leds.fill(Color.black, count + 1, size - count) if count > size
    end
  end
end
