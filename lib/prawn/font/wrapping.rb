module Prawn
  module Font
    
    class AFM
      
      def naive_wrap(string, total_width, font_size)
        output = ""
        string.lines.each do |line|
          line_width = 0
          segments = line.scan(/\S+|\s+/)
          
          segments.each do |segment|
            segment_width = string_width(segment, font_size)
            
            if line_width + segment_width > total_width
              output << "\n"
              output << segment unless segment =~ /\s/
              line_width = 0
            else
              line_width += segment_width
              output << segment
            end
          end
        end
        
        output
      end
      
    end
    
  end
end