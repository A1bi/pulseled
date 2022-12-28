require "./apple_midi/server"
require "./render_scheduler"
require "./led/strip"
require "./led/strip_set"
require "./led/color"
require "./led/visualizer"
require "./effects/clear"
require "./effects/shooting_star"
require "./effects/segments"
require "./effects/perlin_noise"

BRIDGE_HOST = "fd00::123"

a_midi = AppleMidi::Server.new
a_midi.listen

strips = [Led::Strip.new(100), Led::Strip.new(100)]
strip_set = Led::StripSet.new(strips: strips)
strip_set.bridge_client = Led::BridgeClient.new(BRIDGE_HOST)

clear = Effects::Clear.new(strips)
effect = Effects::Segments.new(strips)
effect.colors = [Led::Color.red, Led::Color.green, Led::Color.blue]
effect.changing_segment_sizes = true
effect2 = Effects::ShootingStar.new(strips)
effect2.beat_multiplier = 0.25
effect2.speed = 3
effect3 = Effects::PerlinNoise.new(strips)
effect3.max_brightness = 0.5
effect3.moving_directions = Effects::PerlinNoise::MovingDirection::Vertical
effect2.moving_direction = Effects::ShootingStar::MovingDirection::Radial

scheduler = RenderScheduler.new(a_midi.pulse_counter)
scheduler.effects = [clear, effect3, effect, effect2] of Effects::Effect
scheduler.led_strip_sets = [strip_set]

visualizer = Led::Visualizer.new(strips)

spawn do
  visualizer.start
  loop do
    scheduler.channel.receive
    visualizer.print
  end
end

scheduler.start

strip_set.bridge_client.not_nil!.close
a_midi.close
