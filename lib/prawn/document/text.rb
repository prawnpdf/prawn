# text.rb : Implements PDF text primitives
#
# Copyright May 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
require "zlib"

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

        # replace the users string with a string composed of glyph codes
        # TODO: hackish
        if fonts[@font].data[:Subtype] == :Type0
          unicode_codepoints = text.unpack("U*")
          glyph_codes = unicode_codepoints.collect { |u| enctables[@font].get_glyph_id_for_unicode(u)}
          text = glyph_codes.pack("n*")
        end

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
        @font_metrics = Prawn::Font::Metrics[name]
        case(name)
        when /\.ttf$/
          @font = embed_ttf_font(name)
        else
          @font = register_builtin_font(name)
        end
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

      def wrapped_text(text,options)
        font_size = options[:size] || 12
        font_name = font_registry[fonts[@font]]

        text = @font_metrics.naive_wrap(text, bounds.right, font_size)

        # replace the users string with a string composed of glyph codes
        # FIXME: hackish
        if fonts[@font].data[:Subtype] == :Type0
          unicode_codepoints = text.unpack("U*")
          glyph_codes = unicode_codepoints.collect { |u| enctables[@font].get_glyph_id_for_unicode(u)}
          text = glyph_codes.pack("n*")
        end

        text.lines.each do |e|
          move_text_position(@font_metrics.font_height(font_size))
          add_content %Q{
            BT
            /#{font_name} #{font_size} Tf
            #{@bounding_box.absolute_left} #{y} Td
            #{Prawn::PdfObject(e.chomp)} Tj
            ET
          }
        end
      end

      def embed_ttf_font(file) #:nodoc:
        unless File.file?(file)
          raise ArgumentError, "file #{file} does not exist"
        end

        basename = get_ttf_basename(file)

        raise "Can't detect a postscript name for #{file}" if basename.nil?

        enctables[basename] = get_ttf_enctable(file)

        raise "#{file} missing the required encoding table" if enctables[basename].nil?

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
                         :ItalicAngle => @font_metrics.italic_angle.to_f,
                         :Ascent      => @font_metrics.ascender.to_f,
                         :Descent     => @font_metrics.descender.to_f
                         )

        descendant = ref(:Type           => :Font,
                         :Subtype        => :CIDFontType2, # CID, Type2 == CID, TTF
                         :BaseFont       => basename,
                         :CIDSystemInfo  => {:Registry => "Adobe", :Ordering => "Identity", :Supplement => 0},
                         :FontDescriptor => descriptor#,
                         #:W              => [0, [ 500, 1000, 1000, 1000, 1000, 1000, 1000 ]] # TODO real values here
                        )

        # TODO: Needs ToUnicode (at least)
        fonts[basename] ||= ref(:Type            => :Font,
                                :Subtype         => :Type0,
                                :BaseFont        => basename,
                                :DescendantFonts => [descendant],
                                :Encoding        => :"Identity-H")
        return basename
      end

      def get_ttf_basename(filename)
        ttf = ::Font::TTF::File.new(filename)
        basename = nil
        ttf.get_table(:name).name_records.each do |rec|
          #puts rec.class.methods.sort.inspect
          if rec.name_id == ::Font::TTF::Table::Name::NameRecord::POSTSCRIPT_NAME
            basename = rec.utf8_str.to_sym
          end
        end
        basename
      end

      def get_ttf_enctable(filename)
        ttf = ::Font::TTF::File.new(filename)
        ttf.get_table(:cmap).encoding_tables.find do |t|
          t.class == ::Font::TTF::Table::Cmap::EncodingTable4
        end
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
