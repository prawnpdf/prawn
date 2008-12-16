$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib')) 
require "prawn"        
require "benchmark"   

N=5
     
Benchmark.bmbm do |x|         
  x.report("PNG Type 6") do     
    N.times do
      Prawn::Document.new do 
        image "#{Prawn::BASEDIR}/data/images/dice.png"
      end.render
    end         
  end   
end   