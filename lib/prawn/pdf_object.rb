module Prawn 
                                              
  # This error is raised when Prawn::PdfObject() encounters a Ruby object it
  # cannot convert to PDF
  #
  class ObjectConversionError < StandardError; end
  
  module_function
    
  # Serializes Ruby objects to their PDF equivalents.  Most primitive objects
  # will work as expected, but please note that Name objects are represented 
  # by Ruby Symbol objects and Dictionary objects are represented by Ruby hashes
  # (keyed by symbols)   
  #
  #  Examples:
  #
  #     PdfObject(true)      #=> "true"
  #     PdfObject(false)     #=> "false" 
  #     PdfObject(1.2124)    #=> "1.2124"
  #     PdfObject("foo bar") #=> "(foo bar)"  
  #     PdfObject(:Symbol)   #=> "/Symbol"
  #     PdfObject(["foo",:bar, [1,2]]) #=> "[foo /bar [1 2]]"
  # 
  def PdfObject(obj)
    case(obj) 
    when TrueClass  then "true"
    when FalseClass then "false"
    when Numeric    then String(obj)
    when Array      then "[" << obj.map { |e| PdfObject(e) }.join(' ') << "]"     
    when String 
      if obj =~ /\(|\)/
        obj = obj.gsub("(", '\(').gsub(")",'\)') 
      end
      "(" << obj << ")"
    when Symbol                                                         
       if (obj = obj.to_s) =~ /\s/
         raise ObjectConversionError, "A PDF Name cannot contain whitespace"  
       else
         "/" << obj   
       end 
    when Hash                       
      unless obj.keys.all? { |e| Symbol === e || String === e }
        raise ObjectConversionError, "A PDF Dictionary must be keyed by names"
      end
              
      output = "<< "
      obj.each do |k,v|
        output << PdfObject(k.to_sym) << " " << PdfObject(v) << "\n"
      end   
      output << ">>"        
    else
      raise ObjectConversionError, "This object cannot be serialized to PDF"
    end     
  end   
end