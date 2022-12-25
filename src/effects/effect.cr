require "../led/strip"

module Effects
  class Effect
    getter led_strips : Array(Led::Strip)
    property beat_multiplier : Float64 = 1
    property sync_strips : Bool = false

    def initialize(@led_strips)
      @beat = Float64.new(0)
    end

    def tick(@beat : Float64)
      @led_strips.each.with_index do |strip, i|
        if @sync_strips && i > 0
          strip.copy_from(@led_strips.first)
        else
          render_strip(strip, i.to_u8, beat)
        end
      end
    end

    private def render_strip(strip : Led::Strip, index : UInt8, beat : Float64)
    end

    private def beat_prescaler(scale : UInt8)
      @beat // (4 / scale / @beat_multiplier)
    end
  end
end
