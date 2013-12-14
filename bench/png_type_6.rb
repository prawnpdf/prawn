$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib')) 
require "prawn"        
require "benchmark"   

N=20
     
Benchmark.bmbm do |x|         
  x.report("PNG Type 6") do     
    N.times do
      Prawn::Document.new do 
        image "#{Prawn::DATADIR}/images/dice.png"
      end.render_file("dice.pdf")
    end         
  end   
end   
