require "./apple_midi/pulse_counter"
require "./effects/effect"
require "./led/strip_set"

class RenderScheduler
  FPS               = 30
  SECONDS_PER_FRAME = 1 / FPS
  FALLBACK_BPM      = 120

  @last_quarter : UInt8 = 0
  @last_beat : Time? = nil

  getter channel = Channel(Nil).new
  property effects = [] of Effects::Effect
  property led_strip_sets = [] of Led::StripSet

  def initialize(@pulse_counter : AppleMidi::PulseCounter, @fallback_bpm : UInt8 = FALLBACK_BPM.to_u8)
  end

  def start
    @last_quarter = 0
    update_last_beat

    spawn { watch_beat }

    loop do
      tick
      sleep SECONDS_PER_FRAME
    end
  end

  private def watch_beat
    loop do
      @last_quarter = @pulse_counter.channel.receive
      update_last_beat
    end
  end

  private def tick
    subquarter = unless (last_beat = @last_beat).nil?
      bpm = @pulse_counter.bpm || @fallback_bpm
      (Time.utc - last_beat).total_milliseconds * bpm / 60000
    else
      0.0
    end
    beat = @last_quarter + subquarter

    @effects.each { |effect| effect.tick(beat) }
    @channel.send(nil)
    @led_strip_sets.each(&.send_frame_to_bridge)
  end

  private def update_last_beat
    @last_beat = Time.utc
  end
end
