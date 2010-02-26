module PDF
  class Inspector
    class Text < Inspector                    
      attr_accessor :font_settings, :size, :strings
      attr_accessor :character_spacing, :word_spacing

      def initialize     
        @font_settings = []
        @fonts = {}
        @strings = []
        @character_spacing = []
        @word_spacing = []
      end

      def resource_font(*params)
        @fonts[params[0]] = params[1].basefont
      end

      def set_text_font_and_size(*params)     
        @font_settings << { :name => @fonts[params[0]], :size => params[1] }
      end     

      def show_text(*params)
        @strings << params[0]
      end

      def show_text_with_positioning(*params)      
        # ignore kerning information
        @strings << params[0].reject { |e| Numeric === e }.join
      end

      def set_character_spacing(*params)
        @character_spacing << params[0]
      end

      def set_word_spacing(*params)
        @word_spacing << params[0]
      end
      
    end                                       
  end
end
