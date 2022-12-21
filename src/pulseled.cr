require "./apple_midi/server"

a_midi = AppleMidi::Server.new
a_midi.listen

loop do
  beat = a_midi.pulse_counter.channel.receive
  bpm = a_midi.pulse_counter.bpm
  puts "BEAT #{beat} | BPM #{bpm}"
end

a_midi.close
