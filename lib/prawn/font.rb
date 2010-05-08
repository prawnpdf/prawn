# encoding: utf-8
#
# font.rb : The Prawn font class
#
# Copyright May 2008, Gregory Brown / James Healy. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
require "prawn/font/afm"
require "prawn/font/ttf"
require "prawn/font/dfont"

module Prawn

  class Document
    # Without arguments, this returns the currently selected font. Otherwise,
    # it sets the current font. When a block is used, the font is applied
    # transactionally and is rolled back when the block exits.
    #
    #   Prawn::Document.generate("font.pdf") do
    #     text "Default font is Helvetica"
    #
    #     font "Times-Roman"
    #     text "Now using Times-Roman"
    #
    #     font("Chalkboard.ttf") do
    #       text "Using TTF font from file Chalkboard.ttf"
    #       font "Courier", :style => :bold
    #       text "You see this in bold Courier"
    #     end
    #
    #     text "Times-Roman, again"
    #   end
    #
    # The :name parameter must be a string. It can be one of the 14 built-in
    # fonts supported by PDF, or the location of a TTF file. The Font::AFM::BUILT_INS
    # array specifies the valid built in font values.
    #
    # If a ttf font is specified, the glyphs necessary to render your document
    # will be embedded in the rendered PDF. This should be your preferred option
    # in most cases. It will increase the size of the resulting file, but also 
    # make it more portable.
    #
    # The options parameter is an optional hash providing size and style. To use
    # the :style option you need to map those font styles to their respective font files.
    # See font_families for more information.
    #
    def font(name=nil, options={})
      return((defined?(@font) && @font) || font("Helvetica")) if name.nil?

      if state.pages.empty? && !state.page.in_stamp_stream?
        raise Prawn::Errors::NotOnPage 
      end
      
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
    #
    def set_font(font, size=nil) # :nodoc:
      @font = font
      @font_size = size if size
    end

    # Saves the current font, and then yields. When the block
    # finishes, the original font is restored.
    #
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

    # Hash that maps font family names to their styled individual font names.
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
    # By default the styles :bold, :italic, :bold_italic, and :normal are
    # defined for fonts "Courier", "Times-Roman" and "Helvetica".
    #
    # You probably want to provide those four styles, but are free to define
    # custom ones, like :thin, and use them in font calls.
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

    # Returns the width of the given string using the given font. If :size is not
    # specified as one of the options, the string is measured using the current
    # font size. You can also pass :kerning as an option to indicate whether
    # kerning should be used when measuring the width (defaults to +false+).
    #
    # Note that the string _must_ be encoded properly for the font being used.
    # For AFM fonts, this is WinAnsi. For TTF, make sure the font is encoded as
    # UTF-8. You can use the Font#normalize_encoding method to make sure strings
    # are in an encoding appropriate for the current font.
    #--
    # For the record, this method used to be a method of Font (and still delegates
    # to width computations on Font). However, having the primary interface for
    # calculating string widths exist on Font made it tricky to write extensions
    # for Prawn in which widths are computed differently (e.g., taking formatting
    # tags into account, or the like).
    #
    # By putting width_of here, on Document itself, extensions may easily override
    # it and redefine the width calculation behavior.
    #++
    def width_of(string, options={})
      font.compute_width_of(string, options)
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

    # Shortcut interface for constructing a font object.  Filenames of the form
    # *.ttf will call Font::TTF.new, *.dfont Font::DFont.new, and anything else
    # will be passed through to Font::AFM.new()
    #
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

      @identifier = :"F#{@document.font_registry.size + 1}"

      @references = {}
    end

    # The size of the font ascender in PDF points 
    #
    def ascender
      @ascender / 1000.0 * size
    end

    # The size of the font descender in PDF points
    #
    def descender
      -@descender / 1000.0 * size
    end

    # The size of the recommended gap between lines of text in PDF points
    #
    def line_gap
      @line_gap / 1000.0 * size
    end

    def identifier_for(subset)
      "#{@identifier}.#{subset}".to_sym
    end

    def inspect
      "#{self.class.name}< #{name}: #{size} >"
    end

    # Normalizes the encoding of the string to an encoding supported by the
    # font. The string is expected to be UTF-8 going in. It will be re-encoded
    # and the new string will be returned. For an in-place (destructive)
    # version, see normalize_encoding!.
    #
    def normalize_encoding(string)
      raise NotImplementedError, "subclasses of Prawn::Font must implement #normalize_encoding"
    end

    # Destructive version of normalize_encoding; normalizes the encoding of a
    # string in place.
    #
    def normalize_encoding!(str)
      str.replace(normalize_encoding(str))
    end

    # Gets height of current font in PDF points at the given font size
    #
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
      @document.state.page.fonts.merge!(identifier_for(subset) => @references[subset])
    end

    def identifier_for(subset) #:nodoc:
      "#{@identifier}.#{subset}"
    end

    def inspect #:nodoc:
      "#{self.class.name}< #{name}: #{size} >"
    end

    private

    def size
      @document.font_size
    end

  end

end
