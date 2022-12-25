require "../led/strip"

module Effects
  class Effect
    getter led_strips : Array(Led::Strip)
    property beat_multiplier : Float64 = 1
    property sync_strips : Bool = false

    def initialize(@led_strips)
      @last_beat = UInt8.new(0)
    end

    def tick(quarter, bar_progress)
      if (beat = (quarter * beat_multiplier).to_u8) != @last_beat
        @last_beat = beat
        return if @led_strips.empty?

        before_render

        if @sync_strips
          first_strip = @led_strips.first
          render_strip(first_strip)

          @led_strips[1..].each { |strip| strip.copy_from(first_strip) }
        else
          @led_strips.each { |strip| render_strip(strip) }
        end
      end
    end

    private def before_render
    end

    private def render_strip(strip)
    end
  end
end
