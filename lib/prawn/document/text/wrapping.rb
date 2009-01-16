# encoding: utf-8

# wrapping.rb : Implementation of naive text wrap
#
# Copyright May 2008, Michael Daines. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  class Document
    module Text
      module Wrapping #:nodoc:                
        ruby_18 { $KCODE="U" }
        
        # Gets height of text in PDF points at current font size.
        # Text +:line_width+ must be specified in PDF points.
        #
        # If using an AFM, string *must* be encoded as WinAnsi
        # (Use normalize_encoding to convert)
        #
        def height_of(string, line_width, size=font_size)
          string = naive_wrap(string, line_width, size)
          string.lines.to_a.length * font.height_at(size)
        end

        # TODO: Replace with TeX optimal algorithm
        def naive_wrap(string, line_width, font_size, options = {})
          scan_pattern = options[:mode] == :character ? /./ : /\S+|\s+/                                    
          
          output = ""                
          string.lines.each do |line| 
            accumulated_width = 0        
            segments = line.scan(scan_pattern)
                                          
            segments.each do |segment|    
              segment_width = font.width_of(segment, :size => font_size, :kerning => options[:kerning]) 
        
              if (accumulated_width + segment_width).round > line_width.round
                output = "#{output.sub(/[ \t]*\n?(\n*)\z/, "\n\\1")}"
                
                if segment =~ /\s/           
                  accumulated_width = 0
                else
                  output << segment
                  accumulated_width = segment_width
                end
              else                           
                output << segment
                accumulated_width += segment_width
              end
            end    
          end

          output
        end
        
      end  
    end
  end
end
