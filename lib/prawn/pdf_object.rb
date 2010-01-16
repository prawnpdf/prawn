# encoding: utf-8
#
# pdf_object.rb : Handles Ruby to PDF object serialization
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'prawn/byte_string'

# Top level Module
#
module Prawn 
                                             
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
  def PdfObject(obj, in_content_stream = false)
    case(obj)        
    when NilClass   then "null" 
    when TrueClass  then "true"
    when FalseClass then "false"
    when Numeric    then String(obj)
    when Array
      "[" << obj.map { |e| PdfObject(e, in_content_stream) }.join(' ') << "]"
    when Prawn::LiteralString
      obj = obj.gsub(/[\\\n\(\)]/) { |m| "\\#{m}" }
      "(#{obj})"
    when Time
      obj = obj.strftime("D:%Y%m%d%H%M%S%z").chop.chop + "'00'"
      obj = obj.gsub(/[\\\n\(\)]/) { |m| "\\#{m}" }
      "(#{obj})"
    when Prawn::ByteString
      "<" << obj.unpack("H*").first << ">"
    when String
      obj = "\xFE\xFF" + obj.unpack("U*").pack("n*") unless in_content_stream
      "<" << obj.unpack("H*").first << ">"
     when Symbol                                                         
       if (obj = obj.to_s) =~ /\s/
         raise Prawn::Errors::FailedObjectConversion, 
           "A PDF Name cannot contain whitespace"  
       else
         "/" << obj   
       end 
    when Hash           
      output = "<< "
      obj.each do |k,v|  
        unless String === k || Symbol === k
          raise Prawn::Errors::FailedObjectConversion, 
            "A PDF Dictionary must be keyed by names"
        end                          
        output << PdfObject(k.to_sym, in_content_stream) << " " << 
                  PdfObject(v, in_content_stream) << "\n"
      end  
      output << ">>"  
    when Prawn::Reference
      obj.to_s      
    when Prawn::NameTree::Node
      PdfObject(obj.to_hash)
    when Prawn::NameTree::Value
      PdfObject(obj.name) + " " + PdfObject(obj.value)
    when Prawn::OutlineRoot, Prawn::OutlineItem
      PdfObject(obj.to_hash)
    else
      raise Prawn::Errors::FailedObjectConversion, 
        "This object cannot be serialized to PDF"
    end     
  end   
  
end
