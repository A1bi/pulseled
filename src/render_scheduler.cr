require "./apple_midi/pulse_counter"

class RenderScheduler
  FPS               = 30
  SECONDS_PER_FRAME = 1 / FPS

  @last_quarter : UInt8
  @last_beat : Time?

  getter channel

  def initialize(@pulse_counter : AppleMidi::PulseCounter)
    @last_quarter = 0
    @last_beat = nil
    @channel = Channel(Float64).new
  end

  def start
    spawn { watch_beat }

    loop do
      tick
      sleep SECONDS_PER_FRAME
    end
  end

  private def watch_beat
    loop do
      @last_quarter = @pulse_counter.channel.receive
      @last_beat = Time.utc
    end
  end

  private def tick
    subquarter = unless (last_beat = @last_beat).nil?
      (Time.utc - last_beat).total_milliseconds * @pulse_counter.bpm / 60000
    else
      0.0
    end
    progress = (@last_quarter + subquarter) / 4 % 1
    @channel.send(progress)
  end
end
