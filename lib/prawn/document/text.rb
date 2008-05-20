# text.rb : Implements PDF text primitives
#
# Copyright May 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    module Text
           
      # The built in fonts specified by the Adobe PDF spec.
      BUILT_INS = %w[ Courier Courier-Bold Courier-Oblique Courier-BoldOblique
          Helvetica Helvetica-Bold Helvetica-Oblique Helvetica-BoldOblique
          Times-Roman Times-Bold Times-Italic Times-BoldItalic
          Symbol ZapfDingbats ]                      
                                                  
      # Draws text at a specified position on the page.
      #
      #    pdf.text "Hello World",   :at => [100,100] 
      #    pdf.text "Goodbye World", :at => [50,50], :size => 16
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
      #    pdf.font "Times-Roman"
      #               
      # PERF: Cache or limit calls to this, no need to generate a 
      # new fontmetrics file or re-register the font each time.
      def font(name)  
        @font = name       
        register_font(name)
        @font_metrics = Prawn::Font::AFM[name]   
        set_current_font
      end      
            
      private
      
      def text_width(text,size) 
        @font_metrics.string_width(text,size)  
      end                      
           
      # Not really ready yet. 
      def wrapped_text(text,options)  
        font_size = options[:size] || 12   
        font_name = font_registry[fonts[@font]]
        
        lines = "0 -#{font_size} Td\n" <<
                text.lines.map { |e| Prawn::PdfObject(e) << " Tj\n" }.
                  join("0 -#{font_size} Td\n") 
        
        add_content %Q{
         BT
          /#{font_name} #{font_size} Tf
          #{@bounding_box.absolute_left} #{@bounding_box.absolute_top} Td 
          #{lines} 
          ET           
        }    
      end
      
      def register_font(name) #:nodoc:   
        unless BUILT_INS.include?(name)
          raise Prawn::Errors::UnknownFont, "#{name} is not a known font."
        end    
        fonts[name] ||= ref(:Type     => :Font, 
                            :Subtype  => :Type1, 
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