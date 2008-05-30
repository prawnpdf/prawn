module Prawn
  module Font
    
    class AFM

      def naive_wrap(string, line_width, font_size)
        output = ""
        string.lines.each do |line|
          accumulated_width = 0
          segments = line.scan(/\S+|\s+/)
          
          segments.each do |segment|
            segment_width = string_width(segment, font_size)
      
            if accumulated_width + segment_width > line_width
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
        end
  
        output
      end
      
    end
  
  end
end