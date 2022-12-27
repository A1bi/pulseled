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
      range = segment_range(strip)

      strip.size.times do |i|
        flash = this_strip && i.in?(range) ? 1.0 : 0.0
        apply_to_led(strip, i, color * flash)
      end
    end

    private def segment_range(strip)
      start = @random.rand(0..(strip.size - segment_size))
      start..(start + segment_size)
    end
  end
end
