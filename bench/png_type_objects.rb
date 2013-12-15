require_relative "../lib/prawn"

GC.disable

before = GC.stat

Prawn::Document.new do
  image "#{Prawn::DATADIR}/images/dice.png"
end.render

after = GC.stat
total = after[:total_allocated_object] - before[:total_allocated_object]

puts "allocated objects: #{total}"

