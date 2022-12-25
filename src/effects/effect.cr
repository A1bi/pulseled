require "../led/strip"

module Effects
  class Effect
    getter led_strips : Array(Led::Strip)

    def initialize(@led_strips)
    end

    def tick(quarter, bar_progress)
    end
  end
end
