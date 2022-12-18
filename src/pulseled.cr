require "./apple_midi/server"

a_midi = AppleMidi::Server.new
a_midi.listen
sleep
a_midi.close
