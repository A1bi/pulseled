require "./apple_midi/server"

a_midi = AppleMidi::Server.new
a_midi.listen
a_midi.close
