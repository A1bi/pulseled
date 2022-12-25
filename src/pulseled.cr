require "./apple_midi/server"
require "./render_scheduler"
require "./led/strip"
require "./led/color"
require "./led/visualizer"
require "./effects/segments"

a_midi = AppleMidi::Server.new
a_midi.listen

strips = [Led::Strip.new(60), Led::Strip.new(60)]
visualizer = Led::Visualizer.new(strips)

effect = Effects::Segments.new(strips)
effect.colors = [Led::Color.new(0xff, 0, 0), Led::Color.new(0, 0xff, 0), Led::Color.new(0, 0, 0xff)]
effect.changing_segment_sizes = true

scheduler = RenderScheduler.new(a_midi.pulse_counter)
scheduler.effects = [effect] of Effects::Effect

spawn do
  visualizer.start
  loop do
    scheduler.channel.receive
    visualizer.print
  end
end

scheduler.start

a_midi.close
