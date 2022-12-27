require "../led/strip"
require "../led/color"

module Effects
  class ShootingStar < Effect
    enum MovingDirection
      Right
      Left
      Radial
    end

    property colors : Array(Led::Color) = [Led::Color.white]
    property speed : UInt8 = 1
    property tail_length_divisor : UInt8 = 3
    property moving_direction : MovingDirection = MovingDirection::Right

    private def render_strip(strip, i, beat)
      beat = beat_prescaler(4)
      strip_half = strip.size // 2
      random = Random.new(beat + i)
      color = @colors.sample(random)
      alphas = Array(Float64).new(strip_half, 0)

      total_distance = strip.size * speed
      leading_led = (beat % 1 * total_distance).to_i16
      tail_length = strip.size // tail_length_divisor

      led_range = moving_direction.radial? ? (strip_half...strip.size) : (0...strip.size)
      led_range.each do |j|
        factor = j > leading_led ? speed : 0
        leading_led_multiple = leading_led + total_distance * factor
        tail_start = leading_led_multiple - tail_length

        if j < tail_start
          alpha = 0.0
        else
          distance_to_leading = leading_led_multiple - j
          alpha = 1 - distance_to_leading / tail_length
        end

        j = strip.size - j - 1 if moving_direction.left?
        alphas[j - strip_half] = alpha if moving_direction.radial?

        apply_to_led(strip, j, color * alpha)
      end

      return unless moving_direction.radial?

      (0...strip_half).each do |j|
        copy_index = strip_half - j - 1
        apply_to_led(strip, j, color * alphas[copy_index])
      end
    end
  end
end
