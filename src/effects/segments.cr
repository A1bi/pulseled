require "../led/strip"
require "../led/color"

module Effects
  class Segments < Effect
    property min_segment_size : UInt8 = 5
    property max_segment_size : UInt8 = 10
    property changing_segment_sizes = false
    property min_gap_size : UInt8 = 10
    property max_gap_size : UInt8 = 20
    property even_gap_sizes : Bool = false
    property changing_gap_sizes = false
    property colors : Array(Led::Color) = [Led::Color.white]
    property fading : Bool = true

    @segment_size : UInt8 = 0
    @gap_size : UInt8 = 0

    def initialize(@led_strips)
      super

      @random = Random.new
      change_segment_size
      change_gap_size
    end

    private def render_strip(strip, i, beat)
      beat = beat_prescaler_steps(4)
      easing = fading ? reverse_easing_factor(4) : 1.0
      @random = Random.new(beat + i)

      segment = false
      segment_i = 0
      segment_color = @colors.sample(@random)
      change_segment_size if @changing_segment_sizes
      @gap_size = @random.rand(0.to_u8..min_gap_size)
      first_gap = true

      strip.size.times do |i|
        alpha = segment ? easing : 0.0
        apply_to_led(strip, i, segment_color * alpha)

        segment_i += 1
        if segment && segment_i > @segment_size
          segment = false
          segment_i = 0
        elsif !segment && segment_i > @gap_size
          change_gap_size if !even_gap_sizes || first_gap
          segment = true
          segment_i = 0
          first_gap = false
        end
      end
    end

    private def change_segment_size
      @segment_size = @random.rand(min_segment_size..max_segment_size)
    end

    private def change_gap_size
      @gap_size = @random.rand(min_gap_size..max_gap_size)
    end
  end
end
