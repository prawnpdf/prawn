# encoding: utf-8

# text.rb : Implements PDF text primitives
#
# Copyright May 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
require "zlib"
require "prawn/document/text/box"

module Prawn
  class Document
    module Text
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
      # When using the +:at+ parameter, Prawn will position your text by its
      # baseline, and flow along a single line.
      #
      # When using automatic text flow, Prawn will position your text exactly
      # font.height *below* the baseline, and space each line of text by 
      # font.height + options[:spacing] (default 0)
      #
      # Finally, the drawing position will be moved to the baseline of final 
      # line of text, plus any additional spacing.
      #
      # If you wish to position your flowing text by it's baseline rather
      # than +font.height+ below, simply call <tt>move_up font.height</tt> 
      # before your call to text()
      #
      # === Character Encoding Details: 
      #
      # Note that strings passed to this function should be encoded as UTF-8.
      # If you get unexpected characters appearing in your rendered document, 
      # check this.
      #
      # If the current font is a built-in one, although the string must be
      # encoded as UTF-8, only characters that are available in ISO-8859-1
      # are allowed (transliteration will be attempted).
      #
      # If an empty box is rendered to your PDF instead of the character you 
      # wanted it usually means the current font doesn't include that character.
      #
      def text(text,options={})            
        # we'll be messing with the strings encoding, don't change the users
        # original string
        text = text.to_s.dup                      
        
        # we might also mess with the font
        original_font  = font.name   
              
        options = text_options.merge(options)
        process_text_options(options) 
         
        font.normalize_encoding(text) unless @skip_encoding        

        if options[:at]                
          x,y = translate(options[:at])            
          font.size(options[:size]) { add_text_content(text,x,y,options) }
        else
          wrapped_text(text,options)
        end         

        font(original_font) 
      end 
                          
      # A hash of configuration options, to be used globally by text().
      # 
      #   pdf.text_options.update(:size => 16, :align => :right)   
      #   pdf.text "Hello World" #=> Size 16 w. right alignment
      #
      def text_options
        @text_options ||= {}
      end 
                       
      private 
      
      def process_text_options(options)
        Prawn.verify_options [:style, :kerning, :size, :at, :wrap, 
                              :spacing, :align ], options                               
        
        if options[:style]  
          raise "Bad font family" unless font.family
          font(font.family,:style => options[:style])
        end

        unless options.key?(:kerning)
          options[:kerning] = font.metrics.has_kerning_data?
        end                     

        options[:size] ||= font.size
     end

      def move_text_position(dy)   
         bottom = @bounding_box.stretchy? ? @margin_box.absolute_bottom :
                                            @bounding_box.absolute_bottom
         start_new_page if (y - dy) < bottom
         
         self.y -= dy       
      end

      def wrapped_text(text,options) 
        options[:align] ||= :left      

        font.size(options[:size]) do
          text = font.metrics.naive_wrap(text, bounds.right, font.size, 
            :kerning => options[:kerning], :mode => options[:wrap]) 

          lines = text.lines
                                                       
          lines.each do |e|                                                   
            move_text_position(font.height)                                
                           
            line_width = font.width_of(e)
            case(options[:align]) 
            when :left
              x = @bounding_box.absolute_left
            when :center
              x = @bounding_box.absolute_left + 
                (@bounding_box.width - line_width) / 2.0
            when :right
              x = @bounding_box.absolute_right - line_width 
            end
                               
            add_text_content(e,x,y,options)
            move_text_position(options[:spacing]) if options[:spacing]
          end 
        end
      end  
      
      def add_text_content(text, x, y, options)
        text = font.metrics.convert_text(text,options)

        add_content %Q{
          BT
          /#{font.identifier} #{font.size} Tf
          #{x} #{y} Td
        }  

        add_content Prawn::PdfObject(text, true) <<
          " #{options[:kerning] ? 'TJ' : 'Tj'}\n"

        add_content %Q{
          ET
        }
      end  
    end
  end
end
