module Prawn
  module Font
    class TTF            
      def initialize(font_name)   
        @ttf = ::Font::TTF::File.new(font_name) 
      end     
      
      def cmap
        @cmap ||= @ttf.get_table(:cmap).encoding_tables[-1].charmaps
      end
      # just so we don't forget, a unicode aware TrueType font character
      # width determining function.  TODO: Integrate into text wrapping
      # and font implementation
      def character_width_by_code(code,size)
        @ttf.get_table(:hmtx).metrics[cmap[code]][0] / 2048.0 * size           
      end                   
    end
  end
end