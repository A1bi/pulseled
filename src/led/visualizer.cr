require "colorize"
require "./strip"

module Led
  class Visualizer
    LED_CHAR = '\u2593'
    OUTPUT   = STDOUT

    def initialize(@strips : Array(Strip))
    end

    def print(continuing : Bool)
      OUTPUT.print "\e[A\e[K" * @strips.size if continuing

      @strips.each.with_index do |strip, i|
        OUTPUT.print "#{i + 1}: ["

        strip.leds.each do |color|
          OUTPUT.print LED_CHAR.colorize(color.red, color.green, color.blue)
        end

        OUTPUT.print "]\n"
        OUTPUT.flush
      end
    end
  end
end
