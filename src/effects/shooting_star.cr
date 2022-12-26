require "../led/strip"
require "../led/color"

module Effects
  class ShootingStar < Effect
    property colors : Array(Led::Color) = [Led::Color.white]
    property speed : UInt8 = 1
    property tail_length_divisor : UInt8 = 3

    def initialize(@led_strips)
      super
    end

    private def render_strip(strip, i, beat)
      beat = beat_prescaler(4)
      random = Random.new(beat + i)
      color = @colors.sample(random)

      total_distance = strip.size * speed
      leading_led = (beat % 1 * total_distance).to_i16
      tail_length = strip.size // tail_length_divisor

      strip.size.times do |j|
        factor = j > leading_led ? speed : 0
        leading_led_multiple = leading_led + total_distance * factor
        tail_start = leading_led_multiple - tail_length

        if j < tail_start
          progress = 0.0
        else
          distance_to_leading = leading_led_multiple - j
          progress = 1 - distance_to_leading / tail_length
        end

        strip.leds[j] = color * progress
      end
    end
  end
end
