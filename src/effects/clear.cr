require "./effect"
require "../led/color"

module Effects
  class Clear < Effect
    private def render_strip(strip : Led::Strip, index : UInt8, beat : Float64)
      strip.leds.fill(Led::Color.clear)
    end
  end
end
