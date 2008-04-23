module Prawn
  class Reference
             
   attr_accessor :gen, :data 
    
    def initialize(data) 
      @gen   = 0       
      @data  = data     
    end            
    
    def object 
      output = "#{object_id} #{gen} obj\n" <<
               Prawn::PdfObject(data) << "\n"
      if @stream
        output << "stream\n" << @stream << "\nendstream\n" 
      end
      output << "endobj\n"
    end  
    
    def <<(data)
      (@stream ||= "") << data  
    end  
    
    def to_s            
      "#{object_id} #{gen} R"
    end
      
  end         
  
  module_function
  
  def Reference(data)
    Reference.new(data)
  end
end