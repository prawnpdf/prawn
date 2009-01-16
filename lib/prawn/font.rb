# encoding: utf-8
#
# font.rb : The Prawn font class
#
# Copyright May 2008, Gregory Brown / James Healy. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
require "prawn/font/afm"
require "prawn/font/ttf"
require "prawn/font/dfont"

module Prawn

  class Document
    # Without arguments, this returns the currently selected font. Otherwise,
    # it sets the current font.
    #
    # The single parameter must be a string. It can be one of the 14 built-in
    # fonts supported by PDF, or the location of a TTF file. The Font::AFM::BUILT_INS
    # array specifies the valid built in font values.
    #
    #   pdf.font "Times-Roman"
    #   pdf.font "Chalkboard.ttf"
    #
    # If a ttf font is specified, the glyphs necessary to render your document
    # will be embedded in the rendered PDF. This should be your preferred option
    # in most cases. It will increase the size of the resulting file, but also 
    # make it more portable.
    #
    def font(name=nil, options={})
      return @font || font("Helvetica") if name.nil?

      new_font = find_font(name, options)

      if block_given?
        save_font do
          set_font(new_font, options[:size])
          yield
        end
      else
        set_font(new_font, options[:size])
      end

      @font
    end

    # When called with no argument, returns the current font size.
    # When called with a single argument but no block, sets the current font
    # size.  When a block is used, the font size is applied transactionally and
    # is rolled back when the block exits.  You may still change the font size
    # within a transactional block for individual text segments, or nested calls
    # to font_size.
    #
    #   Prawn::Document.generate("font_size.pdf") do
    #     font_size 16
    #     text "At size 16"
    #
    #     font_size(10) do
    #       text "At size 10"
    #       text "At size 6", :size => 6
    #       text "At size 10"
    #     end
    #
    #     text "At size 16"
    #   end
    #
    # When called without an argument, this method returns the current font
    # size.
    #
    def font_size(points=nil)
      return @font_size unless points
      size_before_yield = @font_size
      @font_size = points
      block_given? ? yield : return
      @font_size = size_before_yield
    end

    # Sets the font directly, given an actual Font object
    # and size.
    def set_font(font, size=nil) # :nodoc:
      @font = font
      @font_size = size if size
    end

    # Saves the current font, and then yields. When the block
    # finishes, the original font is restored.
    def save_font
      @font ||= find_font("Helvetica")
      original_font = @font
      original_size = @font_size

      yield
    ensure
      set_font(original_font, original_size) if original_font
    end

    # Looks up the given font using the given criteria. Once a font has been
    # found by that matches the criteria, it will be cached to subsequent lookups
    # for that font will return the same object.
    #--
    # Challenges involved: the name alone is not sufficient to uniquely identify
    # a font (think dfont suitcases that can hold multiple different fonts in a
    # single file). Thus, the :name key is included in the cache key.
    #
    # It is further complicated, however, since fonts in some formats (like the
    # dfont suitcases) can be identified either by numeric index, OR by their
    # name within the suitcase, and both should hash to the same font object
    # (to avoid the font being embedded multiple times). This is not yet implemented,
    # which means if someone selects a font both by name, and by index, the
    # font will be embedded twice. Since we do font subsetting, this double
    # embedding won't be catastrophic, just annoying.
    # ++
    #
    def find_font(name, options={}) #:nodoc:
      if font_families.key?(name)
        family, name = name, font_families[name][options[:style] || :normal]

        if name.is_a?(Hash)
          options = options.merge(name)
          name = options[:file]
        end
      end

      key = "#{name}:#{options[:font] || 0}"
      font_registry[key] ||= Font.load(self, name, options.merge(:family => family))
    end

    # Hash of Font objects keyed by names
    #
    def font_registry #:nodoc:
      @font_registry ||= {}
    end

    # Hash that maps font family names to their styled individual font names
    #
    # To add support for another font family, append to this hash, e.g:
    #
    #   pdf.font_families.update(
    #    "MyTrueTypeFamily" => { :bold        => "foo-bold.ttf",
    #                            :italic      => "foo-italic.ttf",
    #                            :bold_italic => "foo-bold-italic.ttf",
    #                            :normal      => "foo.ttf" })
    #
    # This will then allow you to use the fonts like so:
    #
    #   pdf.font("MyTrueTypeFamily", :style => :bold)
    #   pdf.text "Some bold text"
    #   pdf.font("MyTrueTypeFamily")
    #   pdf.text "Some normal text"
    #
    # This assumes that you have appropriate TTF fonts for each style you
    # wish to support.
    #
    def font_families
      @font_families ||= Hash.new { |h,k| h[k] = {} }.merge!(
        { "Courier"     => { :bold        => "Courier-Bold",
                             :italic      => "Courier-Oblique",
                             :bold_italic => "Courier-BoldOblique",
                             :normal      => "Courier" },

          "Times-Roman" => { :bold         => "Times-Bold",
                             :italic       => "Times-Italic",
                             :bold_italic  => "Times-BoldItalic",
                             :normal       => "Times-Roman" },

          "Helvetica"   => { :bold         => "Helvetica-Bold",
                             :italic       => "Helvetica-Oblique",
                             :bold_italic  => "Helvetica-BoldOblique",
                             :normal       => "Helvetica" }
        })
    end
  end

  # Provides font information and helper functions.
  #
  class Font

    # The current font name
    attr_reader :name

    # The current font family
    attr_reader :family

    # The options hash used to initialize the font
    attr_reader :options

    def self.load(document,name,options={})
      case name
      when /\.ttf$/   then TTF.new(document, name, options)
      when /\.dfont$/ then DFont.new(document, name, options)
      when /\.afm$/   then AFM.new(document, name, options)
      else                 AFM.new(document, name, options)
      end
    end

    def initialize(document,name,options={}) #:nodoc:
      @document   = document
      @name       = name
      @options    = options

      @family     = options[:family]

      @document.proc_set :PDF, :Text
      @identifier = :"F#{@document.font_registry.size + 1}"

      @references = {}
    end

    def ascender
      @ascender / 1000.0 * size
    end

    def descender
      @descender / 1000.0 * size
    end

    def line_gap
      @line_gap / 1000.0 * size
    end

    def identifier_for(subset)
      "#{@identifier}.#{subset}"
    end

    def inspect
      "#{self.class.name}< #{name}: #{size} >"
    end

    # Returns the width of the given string using the given font. If :size is not
    # specified as one of the options, the string is measured using the current
    # font size. You can also pass :kerning as an option to indicate whether
    # kerning should be used when measuring the width (defaults to +false+).
    #
    # Note that the string _must_ be encoded properly for the font being used.
    # For AFM fonts, this is WinAnsi. For TTF, make sure the font is encoded as
    # UTF-8. You can use the #normalize_encoding method to make sure strings
    # are in an encoding appropriate for the font.
    def width_of(string, options={})
      raise NotImplementedError, "subclasses of Prawn::Font must implement #width_of"
    end

    # Normalizes the encoding of the string to an encoding supported by the font.
    # The string is expected to be UTF-8 going in, and will be reencoded in-place
    # (the argument will be modified directly). The return value is not defined.
    def normalize_encoding(string)
      raise NotImplementedError, "subclasses of Prawn::Font must implement #normalize_encoding"
    end

    def height_at(size)
      @normalized_height ||= (@ascender - @descender + @line_gap) / 1000.0
      @normalized_height * size
    end

    # Gets height of current font in PDF points at current font size
    #
    def height
      height_at(size)
    end

    # Registers the given subset of the current font with the current PDF
    # page. This is safe to call multiple times for a given font and subset,
    # as it will only add the font the first time it is called.
    #
    def add_to_current_page(subset)
      @references[subset] ||= register(subset)
      @document.page_fonts.merge!(identifier_for(subset) => @references[subset])
    end

    private

    def size
      @document.font_size
    end

  end

end
