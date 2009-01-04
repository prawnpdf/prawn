# encoding: utf-8

# reference.rb : Implementation of PDF indirect objects
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'zlib'

module Prawn  
  
  class Reference #:nodoc:
             
   attr_accessor :gen, :data, :offset
   attr_reader :identifier, :stream
    
    def initialize(id,data)
      @identifier = id 
      @gen   = 0       
      @data  = data     
      @compressed = false
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
      raise 'Cannot add data to a stream that is compressed' if @compressed
      (@stream ||= "") << data  
    end  
    
    def to_s            
      "#{@identifier} #{gen} R"
    end

    def compress_stream
      @stream = Zlib::Deflate.deflate(@stream)
      @data[:Filter] = :FlateDecode
      @compressed = true
    end
  end         
  
  module_function
  
  def Reference(*args) #:nodoc:
    Reference.new(*args)
  end     

end
