# text.rb : Implements PDF text primitives
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    module Text
      
      BUILT_INS = %w[ Courier Courier-Bold Courier-Oblique Courier-BoldOblique
          Helvetica Helvetica-Bold Helvetica-Oblique Helvetica-BoldOblique
          Times-Roman Times-Bold Times-Italic Times-BoldItalic
          Symbol ZapfDingbats ]                      
      
      # temporary hack to get text rudiments working, will go away.       
      def register_fonts
        @fonts = {}   
        @font = "Helvetica"
        BUILT_INS.each_with_index do |f,i|       
          @fonts[f] = ref(:Type     => :Font, 
                          :Subtype  => :Type1, 
                          :BaseFont => f.to_sym,
                          :Encoding => :MacRomanEncoding)      
        end
        @proc = ref [:PDF, :Text]
      end   
      
      def font(name)
        @font = name
        set_current_font
      end   
                   
      def set_current_font #:nodoc:
        @font_registry ||= {}
        @font_registry[@fonts[@font]] ||= :"F#{@font_registry.size + 1}"            
                
        @current_page.data[:Resources] ||= { 
          :ProcSet => @proc,             
          :Font    => {}
        }                                                      
        
       @current_page.data[:Resources][:Font].merge!(
         @font_registry[@fonts[@font]] => @fonts[@font] 
       ) 
      end
        
      def text(text,options)        
        x,y = options[:at]
        add_content %Q{
        BT
        /#{@font_registry[@fonts[@font]]} #{options[:size] || 12} Tf 
        #{x} #{y} Td 
        #{Prawn::PdfObject(text)} Tj 
        ET           
        }
      end
      
    end
  end
end