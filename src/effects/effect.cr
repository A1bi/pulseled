require "../led/strip"
require "../led/color"

module Effects
  enum BlendMode
    Normal
    BrightenByAlpha
  end

  class Effect
    getter led_strips : Array(Led::Strip)
    property blend_mode : BlendMode = BlendMode::Normal
    property beat_multiplier : Float64 = 1
    property sync_strips : Bool = false

    def initialize(@led_strips)
      @beat = Float64.new(0)
      @beat_multiplied = Float64.new(0)
    end

    def tick(@beat : Float64)
      @beat_multiplied = @beat * @beat_multiplier

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

    private def apply_to_led(strip : Led::Strip, led_index : Int, color : Led::Color)
      previous_color = strip.leds[led_index]
      case blend_mode
      when BlendMode::BrightenByAlpha
        new_color = previous_color.brighten_by_alpha(color)
      else
        new_color = previous_color + color
      end
      strip.leds[led_index] = new_color
    end

    private def easing_factor(exponent : UInt8 = 2)
      (@beat_multiplied % 1) ** exponent
    end

    private def reverse_easing_factor(exponent : UInt8)
      1 - easing_factor(exponent)
    end

    private def beat_prescaler(scale : UInt8) : Float64
      @beat_multiplied / (4 / scale)
    end

    private def beat_prescaler_steps(scale : UInt8) : UInt16
      beat_prescaler(scale).to_u16
    end
  end
end
