require "perlin_noise"
require "../led/color"

module Effects
  class PerlinNoise < Effect
    property colors : Array(Led::Color) = [Led::Color.red, Led::Color.blue]
    property max_brightness : Float64 = 1.0

    private def render_strip(strip, i, beat)
      beat = beat_prescaler_steps(32)
      perlin = ::PerlinNoise.new
      random = Random.new(i)
      color = colors.sample(random)

      strip.size.times do |i|
        noise = perlin.normalize_noise((beat + i).to_i, 0, 0)
        alpha = [noise, 0.0].max * max_brightness
        apply_to_led(strip, i, color * alpha)
      end
    end
  end
end
