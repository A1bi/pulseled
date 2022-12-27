require "./apple_midi/server"
require "./render_scheduler"
require "./led/strip"
require "./led/color"
require "./led/visualizer"
require "./effects/clear"
require "./effects/shooting_star"
require "./effects/segments"
require "./effects/perlin_noise"

a_midi = AppleMidi::Server.new
a_midi.listen

strips = [Led::Strip.new(100), Led::Strip.new(100)]
visualizer = Led::Visualizer.new(strips)

clear = Effects::Clear.new(strips)
effect = Effects::Segments.new(strips)
effect.colors = [Led::Color.red, Led::Color.green, Led::Color.blue]
effect.changing_segment_sizes = true
effect2 = Effects::ShootingStar.new(strips)
effect2.beat_multiplier = 0.25
effect3 = Effects::PerlinNoise.new(strips)
effect3.max_brightness = 0.5

scheduler = RenderScheduler.new(a_midi.pulse_counter)
scheduler.effects = [clear, effect3, effect] of Effects::Effect

spawn do
  visualizer.start
  loop do
    scheduler.channel.receive
    visualizer.print
  end
end

scheduler.start

a_midi.close
