module AppleMidi
  struct Session
    getter initiator_token : Bytes
    getter peer_ssrc : Bytes
    getter peer_name : String
    getter ssrc : Bytes
    getter peer_control_socket

    def initialize(invitation : Bytes, client_addr)
      @initiator_token = invitation[8..11].dup
      @peer_ssrc = invitation[12..15].dup
      @peer_name = String.new(invitation[16..])
      @ssrc = Random.new.random_bytes(4)

      @peer_control_socket = UDPSocket.new(Socket::Family::INET6)
      @peer_control_socket.connect(client_addr)
    end

    def close
      @peer_control_socket.close
    end
  end
end
