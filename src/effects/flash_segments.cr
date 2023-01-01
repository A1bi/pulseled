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
      beat = beat_prescaler_steps(64)
      @random = Random.new(beat)
      return if !sync_strips && @random.rand(@led_strips.size) == i

      range = segment_range(strip)
      flash = (beat % 2).zero?

      strip.size.times do |j|
        alpha = j.in?(range) && flash ? 1.0 : 0.0
        apply_to_led(strip, j, color * alpha)
      end
    end

    private def segment_range(strip)
      start = @random.rand(0..(strip.size - segment_size))
      start...(start + segment_size)
    end
  end
end
