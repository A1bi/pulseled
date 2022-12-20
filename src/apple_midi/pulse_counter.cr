module AppleMidi
  class PulseCounter
    PULSES_PER_QUARTER = 24
    PULSES_PER_BAR     = PULSES_PER_QUARTER * 4

    @pulses : UInt8

    getter channel

    def initialize
      @pulses = 0
      @channel = Channel(UInt8).new
    end

    def pulse
      if (@pulses += 1) % 24 == 1
        beat = @pulses // 24
        @channel.send(beat)
      end

      if @pulses >= PULSES_PER_BAR
        reset
      end
    end

    def reset
      @pulses = 0
    end
  end
end
