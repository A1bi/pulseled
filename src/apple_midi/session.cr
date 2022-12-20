module AppleMidi
  class Session
    property last_sequence_number : Bytes
    property transmit_feedback : Bool
    getter initiator_token : Bytes
    getter peer_ssrc : Bytes
    getter peer_name : String
    getter ssrc : Bytes

    def initialize(invitation : Bytes)
      @initiator_token = invitation[8..11].dup
      @peer_ssrc = invitation[12..15].dup
      @peer_name = String.new(invitation[16..])
      @ssrc = Random.new.random_bytes(4)
      @last_sequence_number = Bytes[0, 0]
      @transmit_feedback = false
    end
  end
end
