require "./apple_midi/server"

a_midi = AppleMidi::Server.new
a_midi.listen

loop do
  puts "BEAT #{a_midi.pulse_counter.channel.receive}"
end

a_midi.close
