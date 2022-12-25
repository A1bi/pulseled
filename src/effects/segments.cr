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
    @initial_gap : Bool = false

    def initialize(@led_strips)
      super

      change_segment_size
      change_gap_size
    end

    private def before_render
      @initial_gap = !@initial_gap
      change_segment_size if @changing_segment_sizes
      change_gap_size if @changing_gap_sizes
    end

    private def render_strip(strip : Led::Strip)
      segment = @initial_gap
      segment_i = 0
      segment_color = @colors.sample

      strip.size.times do |i|
        color = segment ? segment_color : Led::Color.black
        strip.leds[i] = color

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
      @segment_size = rand(min_segment_size..max_segment_size)
    end

    private def change_gap_size
      @gap_size = rand(min_gap_size..max_gap_size)
    end
  end
end