# encoding: utf-8

# wrapping.rb : Implementation of naive text wrap
#
# Copyright May 2008, Michael Daines. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  class Font #:nodoc:
    module Wrapping #:nodoc:
      
      # TODO: Replace with TeX optimal algorithm
      def naive_wrap(string, line_width, font_size, options = {})
        output = ""                
        accumulated_width = options[:offset] || 0 
        string.lines.each do |line|
          segments = line.scan(/\S+|\s+/)
                                        
          segments.each do |segment|    
            segment_width = string_width(segment, font_size, 
              :kerning => options[:kerning]) 
      
            if (accumulated_width + segment_width).round > line_width.round
              output << "\n"
              
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
          
          accumulated_width = 0
        end
  
        output
      end
      
    end  
  end
end
