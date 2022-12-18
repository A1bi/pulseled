module AppleMidi
  struct Session
    getter initiator_token : Bytes
    getter sender_ssrc : Bytes
    getter peer_name : String

    def initialize(invitation : Bytes)
      @initiator_token = invitation[8..11].dup
      @sender_ssrc = invitation[12..15].dup
      @peer_name = String.new(invitation[16..])
    end
  end
end
