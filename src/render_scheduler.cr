require "./apple_midi/pulse_counter"
require "./effects/effect"

class RenderScheduler
  FPS               = 30
  SECONDS_PER_FRAME = 1 / FPS
  FALLBACK_BPM      = 120

  @last_quarter : UInt8 = 0
  @last_beat : Time? = nil

  getter channel
  property effects : Array(Effects::Effect)

  def initialize(@pulse_counter : AppleMidi::PulseCounter, @fallback_bpm : UInt8 = FALLBACK_BPM.to_u8)
    @channel = Channel(Nil).new
    @effects = [] of Effects::Effect
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
    quarter = @last_quarter + subquarter
    bar_progress = quarter / 4 % 1

    @effects.each { |effect| effect.tick(quarter, bar_progress) }
    @channel.send(nil)
  end

  private def update_last_beat
    @last_beat = Time.utc
  end
end
