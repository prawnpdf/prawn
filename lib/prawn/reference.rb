# encoding: utf-8

# reference.rb : Implementation of PDF indirect objects
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'zlib'

module Prawn  
  
  class Reference #:nodoc:

    attr_accessor :gen, :data, :offset, :stream, :live, :identifier
    
    def initialize(id, data)
      @identifier = id 
      @gen        = 0       
      @data       = data     
      @compressed = false
      @stream     = nil
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
      @data[:Length] ||= @stream.length
      @compressed = true
    end

    def compressed?
      @compressed
    end
    
    # Replaces the data and stream with that of other_ref. Preserves compressed
    # status.
    def replace(other_ref)
      @data       = other_ref.data
      @stream     = other_ref.stream
      @compressed = other_ref.compressed?
    end

    # Marks this and all referenced objects live, recursively.
    def mark_live
      return if @live
      @live = true
      referenced_objects.each { |o| o.mark_live }
    end

    private

    # All objects referenced by this one. Used for GC.
    def referenced_objects(obj=@data)
      case obj
      when Reference
        []
      when Hash
        obj.values.map{|v| [v] + referenced_objects(v) }
      when Array
        obj.map{|v| [v] + referenced_objects(v) }
      else []
      end.flatten.grep(Reference)
    end

  end         

  module_function
  
  def Reference(*args, &block) #:nodoc:
    Reference.new(*args, &block)
  end     

end
