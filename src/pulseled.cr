require "./apple_midi/server"
require "./render_scheduler"
require "./led/strip"
require "./led/color"
require "./led/visualizer"

a_midi = AppleMidi::Server.new
a_midi.listen

strips = [] of Led::Strip
3.times do |i|
  strips << Led::Strip.new(UInt16.new(4 * (i + 1)))
end
visualizer = Led::Visualizer.new(strips)

scheduler = RenderScheduler.new(a_midi.pulse_counter)

spawn do
  first = false
  loop do
    progress = scheduler.channel.receive
    strips.each do |strip|
      strip_progress = (strip.leds.size * progress).to_u8
      strip.leds.size.times do |i|
        strip.leds[i] = i == strip_progress ? Led::Color.white : Led::Color.black
      end
    end
    visualizer.print(first)
    first = true
  end
end

scheduler.start

a_midi.close
