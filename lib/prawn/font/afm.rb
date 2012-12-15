# encoding: utf-8

# prawn/font/afm.rb : Implements AFM font support for Prawn
#
# Copyright May 2008, Gregory Brown / James Healy.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'prawn/encoding'
require 'afm'

module Prawn
  class Font
    class AFM < Font
      BUILT_INS = %w[ Courier Helvetica Times-Roman Symbol ZapfDingbats
                      Courier-Bold Courier-Oblique Courier-BoldOblique
                      Times-Bold Times-Italic Times-BoldItalic
                      Helvetica-Bold Helvetica-Oblique Helvetica-BoldOblique ]

      def unicode?
        false
      end

      def self.metrics_path
        if m = ENV['METRICS']
          @metrics_path ||= m.split(':')
        else
          @metrics_path ||= [
            ".", "/usr/lib/afm",
            "/usr/local/lib/afm",
            "/usr/openwin/lib/fonts/afm",
             Prawn::DATADIR+'/fonts']
        end
      end

      attr_reader :attributes #:nodoc:

      def initialize(document, name, options={}) #:nodoc:
        unless BUILT_INS.include?(name)
          raise Prawn::Errors::UnknownFont, "#{name} is not a known font."
        end

        super

        @@winansi   ||= Prawn::Encoding::WinAnsi.new # parse data/encodings/win_ansi.txt once only
        @@font_data ||= SynchronizedCache.new        # parse each ATM font file once only

        file_name = @name.dup
        file_name << ".afm" unless file_name =~ /\.afm$/
        file_name = file_name[0] == ?/ ? file_name : find_font(file_name)

        font_data = @@font_data[file_name] ||= ::AFM::Font.new(file_name)
        @glyph_table     = build_glyph_table(font_data)
        @kern_pairs      = font_data.kern_pairs
        @kern_pair_table = build_kern_pair_table(@kern_pairs)
        @attributes      = font_data.metadata

        @ascender  = @attributes["Ascender"].to_i
        @descender = @attributes["Descender"].to_i
        @line_gap  = Float(bbox[3] - bbox[1]) - (@ascender - @descender)
      end

      # The font bbox, as an array of integers
      #
      def bbox
        @bbox ||= @attributes['FontBBox'].split(/\s+/).map { |e| Integer(e) }
      end

      # NOTE: String *must* be encoded as WinAnsi
      def compute_width_of(string, options={}) #:nodoc:
        scale = (options[:size] || size) / 1000.0

        if options[:kerning]
          strings, numbers = kern(string).partition { |e| e.is_a?(String) }
          total_kerning_offset = numbers.inject(0.0) { |s,r| s + r }
          (unscaled_width_of(strings.join) - total_kerning_offset) * scale
        else
          unscaled_width_of(string) * scale
        end
      end

      # Returns true if the font has kerning data, false otherwise
      #
      def has_kerning_data?
        @kern_pairs.any?
      end

      # built-in fonts only work with winansi encoding, so translate the
      # string. Changes the encoding in-place, so the argument itself
      # is replaced with a string in WinAnsi encoding.
      #
      def normalize_encoding(text) 
        enc = @@winansi
        text.unpack("U*").collect { |i| enc[i] }.pack("C*")
      rescue ArgumentError
        raise Prawn::Errors::IncompatibleStringEncoding,
          "Arguments to text methods must be UTF-8 encoded"
      end

      # Returns the number of characters in +str+ (a WinAnsi-encoded string).
      #
      def character_count(str)
        str.length
      end

      # Perform any changes to the string that need to happen
      # before it is rendered to the canvas. Returns an array of
      # subset "chunks", where each chunk is an array of two elements.
      # The first element is the font subset number, and the second
      # is either a string or an array (for kerned text).
      #
      # For Adobe fonts, there is only ever a single subset, so
      # the first element of the array is "0", and the second is
      # the string itself (or an array, if kerning is performed).
      #
      # The +text+ parameter must be in WinAnsi encoding (cp1252).
      #
      def encode_text(text, options={})
        [[0, options[:kerning] ? kern(text) : text]]
      end

      def glyph_present?(char)
        if char == "_"
          true
        else
          normalize_encoding(char) != "_"
        end
      end

      private

      def register(subset)
        font_dict = {:Type     => :Font,
                     :Subtype  => :Type1,
                     :BaseFont => name.to_sym}

        # Symbolic AFM fonts (Symbol, ZapfDingbats) have their own encodings
        font_dict.merge!(:Encoding => :WinAnsiEncoding) unless symbolic?

        @document.ref!(font_dict)
      end

      def symbolic?
        attributes["CharacterSet"] == "Special"
      end

      def find_font(file)
        self.class.metrics_path.find { |f| File.exist? "#{f}/#{file}" } + "/#{file}"
      rescue NoMethodError
        raise Prawn::Errors::UnknownFont,
          "Couldn't find the font: #{file} in any of:\n" +
           self.class.metrics_path.join("\n")
      end

      # converts a string into an array with spacing offsets
      # bewteen characters that need to be kerned
      #
      # String *must* be encoded as WinAnsi
      #
      def kern(string)
        kerned = [[]]
        last_byte = nil

        string.bytes do |byte|
          if k = last_byte && @kern_pair_table[[last_byte, byte]]
            kerned << -k << [byte]
          else
            kerned.last << byte
          end         
          last_byte = byte
        end

        kerned.map { |e| 
          e = (Array === e ? e.pack("C*") : e)
          e.respond_to?(:force_encoding) ? e.force_encoding("Windows-1252") : e  
        }
      end
      
      def build_kern_pair_table(kern_pairs)
        character_hash = Hash[Encoding::WinAnsi::CHARACTERS.zip((0..Encoding::WinAnsi::CHARACTERS.size).to_a)]
        kern_pairs.inject({}) do |h,p|
          h[
            [character_hash[p[0]], character_hash[p[1]]]
          ] = p[2]
          h
        end
      end

      def build_glyph_table(font_data)
        (0..255).map do |char|
          metrics = font_data.metrics_for(char)
          metrics ? metrics[:wx] : 0
        end
      end
      
      def unscaled_width_of(string)
        string.bytes.inject(0) do |s,r|
          s + @glyph_table[r]
        end
      end
    end
  end
end
