module AppleMidi
  struct Session
    getter initiator_token : Bytes
    getter peer_ssrc : Bytes
    getter peer_name : String
    getter ssrc : Bytes

    def initialize(invitation : Bytes)
      @initiator_token = invitation[8..11].dup
      @peer_ssrc = invitation[12..15].dup
      @peer_name = String.new(invitation[16..])
      @ssrc = Random.new.random_bytes(4)
    end
  end
end
