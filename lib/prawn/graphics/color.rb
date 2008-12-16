# encoding: utf-8   

# color.rb : Implements color handling
#
# Copyright June 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
module Prawn
  module Graphics
    module Color   
      
      # Sets the fill color.  
      #
      # If a single argument is provided, it should be a 6 digit HTML color 
      # code.
      # 
      #   pdf.fill_color "f0ffc1"
      #
      # If 4 arguments are provided, the color is assumed to be a CMYK value
      # Values range from 0 - 100.
      # 
      #   pdf.fill_color 0, 99, 95, 0
      #
      def fill_color(*color)  
        return @fill_color if color.empty? 
        @fill_color = process_color(*color) 
        set_fill_color
      end 

      alias_method :fill_color=, :fill_color                                                                     

      # Sets the line stroking color.  6 digit HTML color codes are used.
      #
      # If a single argument is provided, it should be a 6 digit HTML color 
      # code.
      # 
      #   pdf.fill_color "f0ffc1"
      #
      # If 4 arguments are provided, the color is assumed to be a CMYK value
      # Values range from 0 - 100.
      # 
      #   pdf.fill_color 0, 99, 95, 0
      #
      def stroke_color(*color)   
        return @stroke_color if color.empty?
        @stroke_color = process_color(*color)
        set_stroke_color
      end

      alias_method :stroke_color=, :stroke_color

      # Provides the following shortcuts:
      #
      #    stroke_some_method(*args) #=> some_method(*args); stroke
      #    fill_some_method(*args) #=> some_method(*args); fill
      #
      def method_missing(id,*args,&block)
        case(id.to_s) 
        when /^fill_and_stroke_(.*)/
          send($1,*args,&block); fill_and_stroke
        when /^stroke_(.*)/
          send($1,*args,&block); stroke 
        when /^fill_(.*)/
          send($1,*args,&block); fill
        else
          super
        end
      end   
      
      module_function
        
      # Converts RGB value array to hex string suitable for use with fill_color 
      # and stroke_color  
      #
      #   >> Prawn::Graphics::Color.rgb2hex([255,120,8])
      #   => "ff7808"     
      #
      def rgb2hex(rgb)
        rgb.map { |e| "%02x" % e }.join
      end  
       
      # Converts hex string into RGB value array:
      #
      #  >> Prawn::Graphics::Color.hex2rgb("ff7808")
      #  => [255, 120, 8]
      #
      def hex2rgb(hex)
        r,g,b = hex[0..1], hex[2..3], hex[4..5]
        [r,g,b].map { |e| e.to_i(16) }
      end 
      
      private
      
      def process_color(*color)   
        case(color.size)
        when 1    
          color[0]    
        when 4
          color
        else
          raise ArgumentError, 'wrong number of arguments supplied'    
        end
      end  
      
      def set_fill_color             
        case @fill_color
        when String
          r,g,b = hex2rgb(@fill_color)
          add_content "%.3f %.3f %.3f rg" % 
             [r / 255.0, g / 255.0, b / 255.0]
        when Array     
          c,m,y,k = *@fill_color
          add_content "%.3f %.3f %.3f %.3f k" % 
            [c / 100.0, m / 100.0, y / 100.0, k / 100.0]
        end
      end

      def set_stroke_color       
        case @stroke_color
        when String
          r,g,b = hex2rgb(@stroke_color)
          add_content "%.3f %.3f %.3f RG" %  
            [r / 255.0, g / 255.0, b / 255.0]
        when Array
          c,m,y,k = *@stroke_color
          add_content "%.3f %.3f %.3f %.3f K" %  
            [c / 100.0, m / 100.0, y / 100.0, k / 100.0]
        end
      end                                       

      def update_colors 
        @fill_color   ||= "000000"
        @stroke_color ||= "000000"
        set_fill_color
        set_stroke_color
      end     
    end
  end
end