require "perlin_noise"
require "../led/color"

module Effects
  class PerlinNoise < Effect
    @[Flags]
    enum MovingDirections
      Horizontal
      Vertical
    end

    property colors : Array(Led::Color) = [Led::Color.red, Led::Color.blue]
    property max_brightness : Float64 = 1.0
    property offset_strips : Bool = true
    property speed : UInt8 = 1
    property step : Float32 = 0.075
    property moving_directions : MovingDirections = MovingDirections::Horizontal

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
        x = y = 0
        if moving_directions.vertical?
          x = j
          y = beat
        end
        if moving_directions.horizontal?
          x = j + beat
        end

        noise = (@perlin.noise(x, y) + 1) / 2.0
        noise = 1 - (noise - 1) if noise > 1

        alpha = [noise, 0.0].max * max_brightness
        apply_to_led(strip, j, color * alpha)
      end
    end
  end
end
