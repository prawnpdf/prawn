$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib')) 
require "prawn"        
require "benchmark"    

N=2000
  
Benchmark.bmbm do |x|         
  x.report("TTF text") do
    Prawn::Document.new {  
       font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"     
       N.times do                                     
         (1..5).each do |i|
           draw_text "Hello Prawn", :at => [200, i * 100]
         end 
         start_new_page     
       end  
    }.render             
  end   
end
