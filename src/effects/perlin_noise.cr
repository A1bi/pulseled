require "perlin_noise"
require "../led/color"

module Effects
  class PerlinNoise < Effect
    property colors : Array(Led::Color) = [Led::Color.red, Led::Color.blue]
    property max_brightness : Float64 = 1.0
    property offset_strips : Bool = true
    property speed : UInt8 = 1
    property step : Float32 = 0.075

    def initialize(@led_strips)
      super

      @perlin = ::PerlinNoise.new
      @perlin.step = step
    end

    private def render_strip(strip, i, beat)
      beat = (beat * 30 * speed).to_i
      random = Random.new(i)
      color = colors.sample(random)
      @perlin.x_offset = (offset_strips ? strip.size * i : 0).to_f32

      strip.size.times do |j|
        position = j + beat
        noise = @perlin.normalize_noise(position, 0, 0)
        alpha = [noise, 0.0].max * max_brightness
        apply_to_led(strip, j, color * alpha)
      end
    end
  end
end
