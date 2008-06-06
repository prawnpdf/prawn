# text.rb : Implements PDF text primitives
#
# Copyright May 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
require "zlib"

module Prawn
  class Document
    module Text
      DEFAULT_FONT_SIZE = 12
      
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
      # pdf.text "Will be wrapped when it hits the edge of your bounding box"
      #
      # Under Ruby 1.8 compatible implementations, all strings passed to this
      # function should be encoded as UTF-8. If you gets unexpected characters
      # appearing in your rendered document, check this.
      #
      # Under a M17n aware implementation (like Ruby 1.9), Prawn will attempt
      # to convert the string to UTF-8 if necessary. An ArgumentError exception 
      # will be raised if this conversion fails.
      #
      # If an empty box is rendered to your PDF instead of the character you 
      # wanted it usually means the current font doesn't include that character.
      # 
      def text(text,options={})
        # TODO: if the current font is a built in one, we can't use the utf-8 
        # string provided by the user. We should convert it to WinAnsi or 
        # MacRoman or some such.

        # if we're running under a M17n aware VM, ensure the string provided is 
        # UTF-8 or can be converted to UTF-8
        if text.respond_to?(:encode)
          begin
            text = text.encode("UTF-8")
          rescue
            raise ArgumentError, 'Strings must be supplied with a UTF-8 ' +
            'encoding, or an encoding that can be converted to UTF-8'
          end
        end

        return wrapped_text(text,options) unless options[:at]
        x,y = translate(options[:at])
        font_size(options[:size] || current_font_size) do
          font_name = font_registry[fonts[@font]]

          # replace the users string with a string composed of glyph codes
          # TODO: hackish
          if fonts[@font].data[:Subtype] == :Type0
            unicode_codepoints = text.unpack("U*")
            glyph_codes = unicode_codepoints.map { |u| 
              enctables[@font].get_glyph_id_for_unicode(u)
            }
            text = glyph_codes.pack("n*")
          end

          add_content %Q{
            BT
            /#{font_name} #{current_font_size} Tf
            #{x} #{y} Td
            #{Prawn::PdfObject(text)} Tj
            ET
          }
        end
      end

      # Sets the current font.
      #
      # The single parameter must be a string. It can be one of the 14 built-in
      # fonts supported by PDF, or the location of a TTF file. The BUILT_INS
      # array specifies the valid built in font values.
      #
      # pdf.font "Times-Roman"
      # pdf.font "Chalkboard.ttf"
      #
      # If a ttf font is specified, the full file will be embedded in the 
      # rendered PDF. This should be your preferred option in most cases. 
      # It will increase the size of the resulting file, but also make it 
      # more portable.
      #
      def font(name)
        @font_metrics = Prawn::Font::Metrics[name]
        case(name)
        when /\.ttf$/
          @font = embed_ttf_font(name)
        else
          @font = register_builtin_font(name)
        end
        set_current_font
      end
      
      # Sets the font size for all text nodes inside the block
      def font_size(size)
        font_size_before_block = @font_size || DEFAULT_FONT_SIZE
        font_size!(size)
        yield
        font_size!(font_size_before_block)
      end
      
      # Sets the default font size for the document
      def font_size!(size)
        @font_size = size unless size == nil
      end
      
      private
      
      def current_font_size
        @font_size || DEFAULT_FONT_SIZE
      end

      def move_text_position(dy)
         if (y - dy) < @margin_box.absolute_bottom
           return start_new_page
         end
         self.y -= dy
      end

      def text_width(text,size)
        @font_metrics.string_width(text,size)
      end

      def wrapped_text(text,options)
        font_size(options[:size] || current_font_size) do
          font_name = font_registry[fonts[@font]]

          text = @font_metrics.naive_wrap(text, bounds.right, current_font_size)

          # THIS CODE JUST DID THE NASTY. FIXME!
          lines = text.lines

          if fonts[@font].data[:Subtype] == :Type0
            lines = lines.map do |line|
              unicode_codepoints = line.chomp.unpack("U*")
              glyph_codes = unicode_codepoints.map { |u| 
                enctables[@font].get_glyph_id_for_unicode(u)
              }
              glyph_codes.pack("n*")
            end
          end

          lines.each do |e|
            move_text_position(@font_metrics.font_height(current_font_size))
            add_content %Q{
              BT
              /#{font_name} #{current_font_size} Tf
              #{@bounding_box.absolute_left} #{y} Td
              #{Prawn::PdfObject(e.to_s.chomp)} Tj
              ET
            }
          end
        end
      end

      def embed_ttf_font(file) #:nodoc:

        ttf_metrics = Prawn::Font::Metrics::TTF.new(file)

        unless File.file?(file)
          raise ArgumentError, "file #{file} does not exist"
        end

        basename = @font_metrics.basename

        raise "Can't detect a postscript name for #{file}" if basename.nil?

        enctables[basename] = @font_metrics.enc_table

        if enctables[basename].nil?
          raise "#{file} missing the required encoding table" 
        end

        font_content    = File.read(file)
        compressed_font = Zlib::Deflate.deflate(font_content)

        fontfile = ref(:Length  => compressed_font.size,
                       :Length1 => font_content.size,
                       :Filter => :FlateDecode )
        fontfile << compressed_font

        # TODO: Not sure what to do about CapHeight, as ttf2afm doesn't
        #       pick it up. Missing proper StemV and flags
        #
        descriptor = ref(:Type        => :FontDescriptor,
                         :FontName    => basename,
                         :FontFile2   => fontfile,
                         :FontBBox    => @font_metrics.bbox,
                         :Flags       => 32, # FIXME: additional flags
                         :StemV       => 0,
                         :ItalicAngle => 0,
                         :Ascent      => @font_metrics.ascender,
                         :Descent     => @font_metrics.descender
                         )

        descendant = ref(:Type           => :Font,
                         :Subtype        => :CIDFontType2, # CID, TTF
                         :BaseFont       => basename,
                         :CIDSystemInfo  => { :Registry   => "Adobe", 
                                              :Ordering   => "Identity", 
                                              :Supplement => 0 },
                         :FontDescriptor => descriptor,
                         :W              => @font_metrics.glyph_widths,
                         :CIDToGIDMap    => :Identity
                        )

        to_unicode_content = @font_metrics.to_unicode_cmap.to_s
        compressed_to_unicode = Zlib::Deflate.deflate(to_unicode_content)
        to_unicode = ref(:Length  => compressed_to_unicode.size,
                         :Length1 => to_unicode_content.size,
                         :Filter => :FlateDecode )
        to_unicode << compressed_to_unicode

        # TODO: Needs ToUnicode (at least)
        fonts[basename] ||= ref(:Type            => :Font,
                                :Subtype         => :Type0,
                                :BaseFont        => basename,
                                :DescendantFonts => [descendant],
                                :Encoding        => :"Identity-H",
                                :ToUnicode       => to_unicode)
        return basename
      end

      def register_builtin_font(name) #:nodoc:
        unless BUILT_INS.include?(name)
          raise Prawn::Errors::UnknownFont, "#{name} is not a known font."
        end
        fonts[name] ||= ref(:Type => :Font,
                            :Subtype => :Type1,
                            :BaseFont => name.to_sym,
                            :Encoding => :MacRomanEncoding)
        return name
      end

      def set_current_font #:nodoc:
        font "Helvetica" unless fonts[@font]
        font_registry[fonts[@font]] ||= :"F#{font_registry.size + 1}"

        @current_page.data[:Resources][:Font].merge!(
          font_registry[fonts[@font]] => fonts[@font]
        )
      end

      def enctables #:nodoc
        @enctables ||= {}
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
