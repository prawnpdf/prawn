module Prawn
  module Core
    module Text

      attr_reader :text_options
      attr_reader :skip_encoding

      ruby_18 { $KCODE="U" }

      # Low level text placement method. All font and size alterations
      # should already be set
      #
      def draw_text!(text, options)
        x,y = map_to_absolute(options[:at])
        add_text_content(text,x,y,options)
      end

      # These should be used as a base. Extensions may build on this list
      VALID_OPTIONS = [:kerning, :size, :style]

      # Low level call to set the current font style and extract text options from
      # an options hash. Should be called from within a save_font block
      #
      def process_text_options(options)
        if options[:style]
          raise "Bad font family" unless font.family
          font(font.family, :style => options[:style])
        end

        # must compare against false to keep kerning on as default
        unless options[:kerning] == false
          options[:kerning] = font.has_kerning_data?
        end

        options[:size] ||= font_size
      end

      # Increases or decreases the space between characters.
      # For horizontal text, a positive value will increase the space.
      # For veritical text, a positive value will decrease the space.
      #
      def character_spacing(amount=nil)
        return @character_spacing || 0 if amount.nil?
        @character_spacing = amount
        add_content "\n%.3f Tc" % amount
        yield
        add_content "\n0 Tc"
        @character_spacing = 0
      end

      # Increases or decreases the space between words.
      # For horizontal text, a positive value will increase the space.
      # For veritical text, a positive value will decrease the space.
      #
      def word_spacing(amount=nil)
        return @word_spacing || 0 if amount.nil?
        @word_spacing = amount
        add_content "\n%.3f Tw" % amount
        yield
        add_content "\n0 Tw"
        @word_spacing = 0
      end

      private

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
