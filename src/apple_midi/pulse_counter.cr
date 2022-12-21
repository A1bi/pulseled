module AppleMidi
  class PulseCounter
    PULSES_PER_QUARTER = 24
    PULSES_PER_BAR     = PULSES_PER_QUARTER * 4
    BPM_REFRESH_RATE   = PULSES_PER_QUARTER * 2

    @pulses : UInt8
    @last_bpm_update : Time?

    getter channel
    getter bpm : Float64

    def initialize
      @pulses = 0
      @bpm = 0
      @channel = Channel(UInt8).new
    end

    def pulse
      if (@pulses += 1) % 24 == 1
        send_beat
      end

      if @pulses % BPM_REFRESH_RATE == 0
        update_bpm
      end

      if @pulses >= PULSES_PER_BAR
        reset_pulses
      end
    end

    def start
      @bpm = 0
      update_last_bpm_timestamp
      reset_pulses
    end

    private def reset_pulses
      @pulses = 0
    end

    private def send_beat
      beat = @pulses // 24
      @channel.send(beat)
    end

    private def update_bpm
      unless (last_update = @last_bpm_update).nil?
        ms_per_quarter = (Time.utc - last_update).total_milliseconds / BPM_REFRESH_RATE * PULSES_PER_QUARTER
        @bpm = 60000 / ms_per_quarter
      end

      update_last_bpm_timestamp
    end

    private def update_last_bpm_timestamp
      @last_bpm_update = Time.utc
    end
  end
end
