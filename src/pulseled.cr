require "./apple_midi/server"
require "./led/strip"
require "./led/color"
require "./led/visualizer"

strips = [] of Led::Strip
3.times do |i|
  strips << Led::Strip.new(UInt16.new(5 * (i + 1)))
end
visualizer = Led::Visualizer.new(strips)

spawn do
  max_iterations = strips.last.leds.size * 10
  max_iterations.times do |i|
    max_iterations.times do |j|
      strips.each do |strip|
        led = j % strip.leds.size
        strip.leds[led] = led == i % strip.leds.size ? Led::Color.white : Led::Color.black
      end
    end
    visualizer.print(i > 0)
    sleep 0.1
  end
end

a_midi = AppleMidi::Server.new
a_midi.listen

loop do
  beat = a_midi.pulse_counter.channel.receive
  bpm = a_midi.pulse_counter.bpm
  puts "BEAT #{beat} | BPM #{bpm}"
end

a_midi.close
