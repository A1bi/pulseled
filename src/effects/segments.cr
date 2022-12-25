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

    @segment_size : UInt8 = 0
    @gap_size : UInt8 = 0

    def initialize(@led_strips)
      super

      @random = Random.new
      change_segment_size
      change_gap_size
    end

    private def render_strip(strip, i, beat)
      beat = beat_prescaler(4)
      @random = Random.new(beat + i)

      segment = (beat % 2).zero?
      segment_i = 0
      segment_color = @colors.sample(@random)
      change_segment_size if @changing_segment_sizes
      change_gap_size if @changing_gap_sizes

      strip.size.times do |i|
        strip.leds[i] = segment ? segment_color : Led::Color.black

        segment_i += 1
        if segment && segment_i > @segment_size
          segment = false
          segment_i = 0
          change_gap_size unless even_gap_sizes
        elsif !segment && segment_i > @gap_size
          segment = true
          segment_i = 0
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
