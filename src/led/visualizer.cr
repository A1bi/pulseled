require "colorize"
require "./strip"

module Led
  class Visualizer
    LED_CHAR = '\u2593'
    OUTPUT   = STDOUT

    def initialize(@strips : Array(Strip))
    end

    def start
      OUTPUT.print "\n" * @strips.size
    end

    def print
      OUTPUT.print "\e[A\e[K" * @strips.size

      @strips.each.with_index do |strip, i|
        OUTPUT.print "#{i + 1}: ["

        strip.leds.each do |color|
          OUTPUT.print(
            LED_CHAR.colorize(
              (UInt8::MAX * color.red).to_u8,
              (UInt8::MAX * color.green).to_u8,
              (UInt8::MAX * color.blue).to_u8
            )
          )
        end

        OUTPUT.print "]\n"
        OUTPUT.flush
      end
    end
  end
end
