$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')   
require "prawn"        
require "benchmark"   

#=begin
N=5
     
Benchmark.bmbm do |x|         
  x.report("PNG Type 6") do     
    N.times do
#=end
      Prawn::Document.new do 
        image "#{Prawn::BASEDIR}/data/images/dice.png"
      end.render
#=begin
    end         
  end   
end   
#=end
