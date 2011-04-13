# encoding: utf-8
#
# pdf_object.rb : Handles Ruby to PDF object serialization
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

# Top level Module
#
module Prawn 
  module Core #:nodoc:
                                             
    module_function

    ruby_18 do
      def utf8_to_utf16(str)
        utf16 = "\xFE\xFF"

        str.unpack("U*").each do |cp|
          if cp < 0x10000 # Basic Multilingual Plane
            utf16 << [cp].pack("n")
          else
            # pull out high/low 10 bits
            hi, lo = (cp - 0x10000).divmod(2**10)
            # encode a surrogate pair
            utf16 << [0xD800 + hi, 0xDC00 + lo].pack("n*")
          end
        end

        utf16
      end

      def utf16_to_utf8(str)
        # Strip the BOM if it's present
        str = str[2..-1] if str =~ /\A\xFE\xFF/n

        # Build an array of code points while handling surrogate pairs
        codepoints = []
        hi = nil    # for handling of surrogate pairs
        str.unpack("n*").each do |cp|
          if cp >= 0xd800 and cp <= 0xdbff    # surrogate pairs - high surrogate
            codepoints << 0xfffd if hi    # decode error - two high surrogates mashed together
            hi = cp & 0x3ff
            next
          elsif cp >= 0xdc00 and cp <= 0xdfff    # surrogate pairs - low surrogate
            if hi
              lo = cp & 0x3ff
              codepoints << ((hi << 10) | lo) + 0x10000
              hi = nil
            else    # decode error - add the "unknown" character
              codepoints << 0xfffd
            end
            next
          end
          if hi
            # decode error - high surrogate without low surrogate
            codepoints << 0xfffd
            hi = nil
          end
          codepoints << cp
        end
        codepoints << 0xfffd if hi    # decode error - trailing high surrogate

        # encode as UTF-8
        codepoints.pack("U*")
      end
    end

    ruby_19 do
      def utf8_to_utf16(str)
        str = str.dup.force_encoding('UTF-8')
        "\xFE\xFF".force_encoding("UTF-16BE") + str.encode("UTF-16BE")
      end

      def utf16_to_utf8(str)
        str = str.dup.force_encoding("ASCII-8BIT")
        str = str[2..-1] if str =~ /\A\xFE\xFF/n   # Strip the BOM if it's present
        str.force_encoding('UTF-16BE').encode("UTF-8")
      end
    end
      
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
      when Prawn::Core::LiteralString
        obj = obj.gsub(/[\\\n\r\t\b\f\(\)]/n) { |m| "\\#{m}" }
        "(#{obj})"
      when Time
        obj = obj.strftime("D:%Y%m%d%H%M%S%z").chop.chop + "'00'"
        obj = obj.gsub(/[\\\n\r\t\b\f\(\)]/n) { |m| "\\#{m}" }
        "(#{obj})"
      when Prawn::Core::ByteString
        "<" << obj.unpack("H*").first << ">"
      when String
        obj = utf8_to_utf16(obj) unless in_content_stream
        "<" << obj.unpack("H*").first << ">"
       when Symbol                                                         
         "/" + obj.to_s.unpack("C*").map { |n|
          if n < 33 || n > 126 || [35,40,41,47,60,62].include?(n)
            "#" + n.to_s(16).upcase
          else
            [n].pack("C*")
          end
         }.join
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
      when Prawn::Core::Reference
        obj.to_s      
      when Prawn::Core::NameTree::Node
        PdfObject(obj.to_hash)
      when Prawn::Core::NameTree::Value
        PdfObject(obj.name) + " " + PdfObject(obj.value)
      when Prawn::OutlineRoot, Prawn::OutlineItem
        PdfObject(obj.to_hash)
      else
        raise Prawn::Errors::FailedObjectConversion, 
          "This object cannot be serialized to PDF (#{obj.inspect})"
      end     
    end   
  end
end
