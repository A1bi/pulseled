module AppleMidi
  class Session
    PULSES_PER_QUARTER = 24

    getter initiator_token : Bytes
    getter peer_ssrc : Bytes
    getter peer_name : String
    getter ssrc : Bytes

    def initialize(invitation : Bytes)
      @initiator_token = invitation[8..11].dup
      @peer_ssrc = invitation[12..15].dup
      @peer_name = String.new(invitation[16..])
      @ssrc = Random.new.random_bytes(4)
      @clock = UInt16.new(0)
    end

    def pulse_clock
      if (@clock += 1) >= PULSES_PER_QUARTER
        reset_clock
      elsif @clock == 1
        return true
      end
      false
    end

    def reset_clock
      @clock = 0
    end
  end
end
