module Prawn
  class Reference
             
   attr_accessor :gen, :data, :offset
   attr_reader :identifier, :stream
    
    def initialize(id,data)
      @identifier = id 
      @gen   = 0       
      @data  = data     
    end            
    
    def object 
      output = "#{@identifier} #{gen} obj\n" <<
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
      "#{@identifier} #{gen} R"
    end
      
  end         
  
  module_function
  
  def Reference(*args)
    Reference.new(*args)
  end
end