# text.rb : Implements PDF text primitives
#
# Copyright May 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
 
module Prawn
  class Document
    module Text
           
      # The built in fonts specified by the Adobe PDF spec.
      BUILT_INS = %w[ Courier Courier-Bold Courier-Oblique Courier-BoldOblique
                      Helvetica Helvetica-Bold Helvetica-Oblique 
                      Helvetica-BoldOblique Times-Roman Times-Bold Times-Italic 
                      Times-BoldItalic Symbol ZapfDingbats ]
                                                  
      # Draws text on the page. If a point is specified via the <tt>:at</tt>
      # option the text will begin exactly at that point, and the string is
      # assumed to be pre-formatted to properly fit the page.
      #
      # When <tt>:at</tt> is not specified, Prawn attempts to wrap the text to
      # fit within your current bounding box (or margin box if no bounding box
      # is being used ). Text will flow onto the next page when it reaches
      # the bottom of the margin_box. Text wrap in Prawn does not re-flow
      # linebreaks, so if you want fully automated text wrapping, be sure to
      # remove newlines before attempting to draw your string.
      #
      # pdf.text "Hello World", :at => [100,100]
      # pdf.text "Goodbye World", :at => [50,50], :size => 16
      # pdf.text "This will be wrapped when it hits the edge of your bounding box"
      #
      def text(text,options={})
        return wrapped_text(text,options) unless options[:at]
        x,y = translate(options[:at])
        font_size = options[:size] || 12
        font_name = font_registry[fonts[@font]]
        
        add_content %Q{
          BT
          /#{font_name} #{font_size} Tf
          #{x} #{y} Td
          #{Prawn::PdfObject(text)} Tj
          ET
        } 
      end
              
      # Sets the current font.
      #
      # For the time being, name must be one of the BUILT_INS
      #
      # pdf.font "Times-Roman"
      #
      # PERF: Cache or limit calls to this, no need to generate a
      # new fontmetrics file or re-register the font each time.  
      #
      def font(name)
        @font = name
        register_font(name)
        @font_metrics = Prawn::Font::AFM[name]
        set_current_font
      end
            
      private
      
      def move_text_position(dy)
         if (y - dy) < @margin_box.absolute_bottom
           return start_new_page
         end
         self.y -= dy
      end
      
      def text_width(text,size)
        @font_metrics.string_width(text,size)
      end
           
      # Not really ready yet.
      def wrapped_text(text,options)
        font_size = options[:size] || 12
        font_name = font_registry[fonts[@font]]
        
        text = @font_metrics.naive_wrap(text, bounds.right, font_size)
        
        text.lines.each do |e|
          move_text_position(font_size)
          add_content %Q{
            BT
            /#{font_name} #{font_size} Tf
            #{@bounding_box.absolute_left} #{y} Td
            #{Prawn::PdfObject(e)} Tj
            ET
          }  
        end
      end
      
      def register_font(name) #:nodoc:
        unless BUILT_INS.include?(name)
          raise Prawn::Errors::UnknownFont, "#{name} is not a known font."
        end
        fonts[name] ||= ref(:Type => :Font,
                            :Subtype => :Type1,
                            :BaseFont => name.to_sym,
                            :Encoding => :MacRomanEncoding)
      end
                   
      def set_current_font #:nodoc:
        font "Helvetica" unless fonts[@font]
        font_registry[fonts[@font]] ||= :"F#{font_registry.size + 1}"
          
        @current_page.data[:Resources][:Font].merge!(
          font_registry[fonts[@font]] => fonts[@font]
        )
      end
      
      def font_registry #:nodoc:
        @font_registry ||= {}
      end
      
      def font_proc #:nodoc:
        @font_proc ||= ref [:PDF, :Text]
      end
      
      def fonts #:nodoc:
        @fonts ||= {}
      end
          
    end
  end
end