$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
                                    
content = <<-EOS
How does
Prawn    deal     with
   white
     space 
     
       and    
       
       line
       breaks?
EOS

Prawn::Document.generate("flow.pdf") do |pdf|      
  pdf.text content, :size => 10
end