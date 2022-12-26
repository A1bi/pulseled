require "../led/strip"
require "../led/color"

module Effects
  class FlashSegments < Effect
    property segment_size = 10
    property color : Led::Color = Led::Color.white

    def initialize(@led_strips)
      super

      @random = Random.new
    end

    private def render_strip(strip, i, beat)
      beat = beat_prescaler_steps(16)
      @random = Random.new(beat)

      this_strip = beat % @led_strips.size == i
      start = @random.rand(0..(strip.size - segment_size))

      strip.size.times do |i|
        flash = this_strip && i.in?(start..(start + segment_size))
        strip.leds[i] = flash ? color : Led::Color.black
      end
    end
  end
end
