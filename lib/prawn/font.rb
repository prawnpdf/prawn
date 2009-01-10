# encoding: utf-8
#
# font.rb : The Prawn font class
#
# Copyright May 2008, Gregory Brown / James Healy. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
require "prawn/font/afm"
require "prawn/font/ttf"

module Prawn

  class Document
    # Without arguments, this returns the currently selected font. Otherwise,
    # it sets the current font.
    #
    # The single parameter must be a string. It can be one of the 14 built-in
    # fonts supported by PDF, or the location of a TTF file. The BUILT_INS
    # array specifies the valid built in font values.
    #
    #   pdf.font "Times-Roman"
    #   pdf.font "Chalkboard.ttf"
    #
    # If a ttf font is specified, the full file will be embedded in the
    # rendered PDF. This should be your preferred option in most cases.
    # It will increase the size of the resulting file, but also make it
    # more portable.
    #
    def font(name=nil, options={})
      return @font || font("Helvetica") if name.nil?

      if block_given?
        original_name = font.name
        original_size = font.size
      end

      @font = find_font(name, options)
      @font.size = options[:size] if options[:size]

      if block_given?
        yield
        font(original_name, :size => original_size)
      else
        @font
      end
    end

    # Looks up the given font name. Once a font has been found by that name,
    # it will be cached to subsequent lookups for that font will return the
    # same object.
    #
    def find_font(name, options={}) #:nodoc:
      if font_families.key?(name)
        family, name = name, font_families[name][options[:style] || :normal]
      end

      font_registry[name] ||= Font.load(self, name, options.merge(:family => family))
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

    DEFAULT_SIZE = 12

    # The font metrics object
    attr_reader   :metrics

    # The current font name
    attr_reader :name

    # The current font family
    attr_reader :family

    # Sets the size of the current font:
    #
    #   font.size = 16
    #
    attr_writer   :size

    def self.load(document,name,options={})
      case name
      when /\.ttf$/ then TTF.new(document, name, options)
      when /\.afm$/ then AFM.new(document, name, options)
      else               AFM.new(document, name, options)
      end
    end

    def initialize(document,name,options={}) #:nodoc:
      @document   = document
      @name       = name
      @family     = options[:family]

      @document.proc_set :PDF, :Text
      @size       = DEFAULT_SIZE
      @identifier = :"F#{@document.font_registry.size + 1}"

      @references = {}
    end

    def identifier_for(subset)
      "#{@identifier}.#{subset}"
    end

    def inspect
      "#{self.class.name}< #{name}: #{size} >"
    end

    # Sets the default font size for use within a block. Individual overrides
    # can be used as desired. The previous font size will be restored after the
    # block.
    #
    # Prawn::Document.generate("font_size.pdf") do
    #   font.size = 16
    #   text "At size 16"
    #
    #   font.size(10) do
    #     text "At size 10"
    #     text "At size 6", :size => 6
    #     text "At size 10"
    #   end
    #
    #   text "At size 16"
    # end
    #
    # When called without an argument, this method returns the current font
    # size.
    #
    def size(points=nil)
      return @size unless points
      size_before_yield = @size
      @size = points
      yield
      @size = size_before_yield
    end

    def font_height_at(size)
      (raw_ascender - raw_descender + raw_line_gap) / 1000.0 * size
    end

    # Gets height of current font in PDF points at current font size
    #
    def height
      font_height_at(@size)
    end

    # The height of the ascender at the current font size in PDF points
    #
    def ascender
      @ascender ||= raw_ascender / 1000.0 * @size
    end

    # The height of the descender at the current font size in PDF points
    #
    def descender
      @descender ||= raw_descender / 1000.0 * @size
    end

    # The height of the line gap at the current font size in PDF points
    #
    def line_gap
      @line_gap ||= raw_line_gap / 1000.0 * @size
    end

    # Registers the given subset of the current font with the current PDF
    # page. This is safe to call multiple times for a given font and subset,
    # as it will only add the font the first time it is called.
    #
    def add_to_current_page(subset)
      @references[subset] ||= embed(subset)
      @document.page_fonts.merge!(identifier_for(subset) => @references[subset])
    end
  end

end
