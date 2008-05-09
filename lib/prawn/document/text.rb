# text.rb : Implements PDF text primitives
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    module Text                       
      
      # temporary hack to get text rudiments working, will go away.       
      def register_font
        @font = ref(:Type     => :Font, 
                    :Subtype  => :Type1, 
                    :Name     => :F1,
                    :BaseFont => :Helvetica,
                    :Encoding => :MacRomanEncoding)  
        @proc = ref [:PDF, :Text]
      end       
                   
      # temporary hack to get text rudiments working, will go away.
      def set_page_font
        @current_page.data[:Resources] =  { 
          :ProcSet => @proc, 
          :Font    => { :F1 => @font }   
        }
      end
        
      def text(text,options)        
        x,y = options[:at]
        add_content %Q{
        BT
        /F1 #{options[:size] || 12} Tf 
        #{x} #{y} Td 
        #{Prawn::PdfObject(text)} Tj 
        ET           
        }
      end
      
    end
  end
end