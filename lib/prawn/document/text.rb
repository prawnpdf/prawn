# encoding: utf-8

# text.rb : Implements PDF text primitives
#
# Copyright May 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
require "zlib"
require "prawn/document/text/box"
require "prawn/document/text/wrapping"

module Prawn
  class Document
    module Text
      include Wrapping
      
      # Draws text on the page. If a point is specified via the +:at+
      # option the text will begin exactly at that point, and the string is
      # assumed to be pre-formatted to properly fit the page.
      # 
      #   pdf.text "Hello World", :at => [100,100]
      #   pdf.text "Goodbye World", :at => [50,50], :size => 16
      #
      # When +:at+ is not specified, Prawn attempts to wrap the text to
      # fit within your current bounding box (or margin_box if no bounding box
      # is being used ). Text will flow onto the next page when it reaches
      # the bottom of the bounding box. Text wrap in Prawn does not re-flow
      # linebreaks, so if you want fully automated text wrapping, be sure to
      # remove newlines before attempting to draw your string.  
      #
      #   pdf.text "Will be wrapped when it hits the edge of your bounding box"
      #   pdf.text "This will be centered", :align => :center
      #   pdf.text "This will be right aligned", :align => :right     
      #
      #  Wrapping is done by splitting words by spaces by default.  If your text
      #  does not contain spaces, you can wrap based on characters instead:
      #
      #   pdf.text "This will be wrapped by character", :wrap => :character  
      #
      # If your font contains kerning pairs data that Prawn can parse, the 
      # text will be kerned by default.  You can disable this feature by passing
      # <tt>:kerning => false</tt>.
      #
      # === Text Positioning Details:
      #
      # When using the :at parameter, Prawn will position your text by the
      # left-most edge of its baseline, and flow along a single line.  (This
      # means that :align will not work)
      # 
      #
      # Otherwise, the text is positioned at font.ascender below the baseline,
      # making it easy to use this method within bounding boxes and spans.
      #
      # == Rotation
      #
      # Text can be rotated before it is placed on the canvas by specifying the
      # +:rotate+ option with a given angle. Rotation occurs counter-clockwise.
      #
      # == Encoding
      #
      # Note that strings passed to this function should be encoded as UTF-8.
      # If you get unexpected characters appearing in your rendered document, 
      # check this.
      #
      # If the current font is a built-in one, although the string must be
      # encoded as UTF-8, only characters that are available in WinAnsi
      # are allowed.
      #
      # If an empty box is rendered to your PDF instead of the character you 
      # wanted it usually means the current font doesn't include that character.
      #
      def text(text,options={})            
        # we'll be messing with the strings encoding, don't change the users
        # original string
        text = text.to_s.dup                      
        
        save_font do
          options = @text_options.merge(options)
          process_text_options(options) 
           
          font.normalize_encoding!(text) unless @skip_encoding        

          if options[:at]                

            if options[:align]
              raise ArgumentError, "The :align option does not work with :at" 
            end

            x,y = translate(options[:at])            
            font_size(options[:size]) { add_text_content(text,x,y,options) }
          else
            if options[:rotate]
              raise ArgumentError, "Rotated text may only be used with :at" 
            end
            wrapped_text(text,options)
          end         
        end
      end 

      private 
                        
      def process_text_options(options)
        Prawn.verify_options [:style, :kerning, :size, :at, :wrap, 
                              :leading, :align, :rotate, :final_gap ], options                               
        
        if options[:style]  
          raise "Bad font family" unless font.family
          font(font.family,:style => options[:style])
        end

        unless options.key?(:kerning)
          options[:kerning] = font.has_kerning_data?
        end                     

        options[:size] ||= font_size
     end

      def move_text_position(dy)   
         bottom = @bounding_box.stretchy? ? @margin_box.absolute_bottom :
                                            @bounding_box.absolute_bottom

         @bounding_box.move_past_bottom if (y - dy) < bottom
         
         self.y -= dy       
      end

      def wrapped_text(text,options) 
        options[:align] ||= :left      

        font_size(options[:size]) do
          text = naive_wrap(text, bounds.width, font_size, 
            :kerning => options[:kerning], :mode => options[:wrap]) 

          lines = text.lines.to_a
          last_gap_before = options.fetch(:final_gap, true) ? lines.length : lines.length-1
                                                       
          lines.each_with_index do |e,i|         
            move_text_position(font.ascender)
                           
            line_width = width_of(e, :kerning => options[:kerning])
            case(options[:align]) 
            when :left
              x = @bounding_box.left_side
            when :center
              x = @bounding_box.left_side +
                (@bounding_box.width - line_width) / 2.0
            when :right
              x = @bounding_box.right_side - line_width
            end
                               
            add_text_content(e,x,y,options)
            
            if i < last_gap_before
              move_text_position(font.line_gap - font.descender)
              move_text_position(options[:leading]) if options[:leading]
            end
          end 
        end
      end  

      def add_text_content(text, x, y, options)
        chunks = font.encode_text(text,options)

        add_content "\nBT"
        if options[:rotate]
          rad = options[:rotate].to_i * Math::PI / 180
          arr = [ Math.cos(rad), Math.sin(rad), -Math.sin(rad), Math.cos(rad), x, y ]
          add_content "%.3f %.3f %.3f %.3f %.3f %.3f Tm" % arr
        else
          add_content "#{x} #{y} Td"
        end

        chunks.each do |(subset, string)|
          font.add_to_current_page(subset)
          add_content "/#{font.identifier_for(subset)} #{font_size} Tf"

          operation = options[:kerning] && string.is_a?(Array) ? "TJ" : "Tj"
          add_content Prawn::PdfObject(string, true) << " " << operation
        end
        add_content "ET\n"
      end
    end
  end
end
