# frozen_string_literal: true

require_relative 'formatted/wrap'

module Prawn
  module Text
    # Fancy pretty text.
    module Formatted
      # @group Stable API

      # Draws the requested formatted text into a box.
      #
      # When the text overflows the rectangle shrink to fit or truncate the
      # text. Text boxes are independent of the document y position.
      #
      # @example
      #   formatted_text_box([{ :text => "hello" },
      #                       { :text => "world",
      #                         :size => 24,
      #                         :styles => [:bold, :italic] }])
      #
      # @param array [Array<Hash{Symbol => any}>]
      #   Formatted text is an array of hashes, where each hash defines text and
      #   format information. The following hash options are supported:
      #
      #   - `:text` --- the text to format according to the other hash options.
      #   - `:styles` --- an array of styles to apply to this text. Available
      #     styles include `:bold`, `:italic`, `:underline`, `:strikethrough`,
      #     `:subscript`, and `:superscript`.
      #   - `:size` ---a number denoting the font size to apply to this text.
      #   - `:character_spacing` --- a number denoting how much to increase or
      #     decrease the default spacing between characters.
      #   - `:font` --- the name of a font. The name must be an AFM font with
      #     the desired faces or must be a font that is already registered using
      #     {Prawn::Document#font_families}.
      #   - `:color` --- anything compatible with
      #     {Prawn::Graphics::Color#fill_color} and
      #     {Prawn::Graphics::Color#stroke_color}.
      #   - :link` --- a URL to which to create a link. A clickable link will be
      #     created to that URL. Note that you must explicitly underline and
      #     color using the appropriate tags if you which to draw attention to
      #     the link.
      #   - `:anchor` --- a destination that has already been or will be
      #     registered using
      #     `PDF::Core::Destinations#add_dest`{:.language-plain}. A clickable
      #     link will be created to that destination. Note that you must
      #     explicitly underline and color using the appropriate tags if you
      #     which to draw attention to the link.
      #   - `:local` --- a file or application to be opened locally. A clickable
      #     link will be created to the provided local file or application. If
      #     the file is another PDF, it will be opened in a new window. Note
      #     that you must explicitly underline and color using the appropriate
      #     options if you which to draw attention to the link.
      #   - `:draw_text_callback` --- if provided, this Proc will be called
      #     instead of {#draw_text!} once per fragment for every low-level
      #     addition of text to the page.
      #   - `:callback` --- an object (or array of such objects) with two
      #     methods: `#render_behind`{:.language-plain} and
      #     `#render_in_front`{:.language-plain}, which are called immediately
      #     prior to and immediately after rendering the text fragment and which
      #     are passed the fragment as an argument.
      # @param options [Hash{Symbol => any}]
      #   Accepts the same options as {Text::Box}.
      #
      # @return [Array<Hash>]
      #   A formatted text array representing any text that did not print under
      #   the current settings.
      #
      # @raise [Prawn::Text::Formatted::Arranger::BadFontFamily]
      #   If no font family is defined for the current font.
      # @raise [Prawn::Errors::CannotFit]
      #   If not wide enough to print any text.
      def formatted_text_box(array, options = {})
        Text::Formatted::Box.new(array, options.merge(document: self)).render
      end
    end
  end
end

require_relative 'formatted/box'
require_relative 'formatted/parser'
require_relative 'formatted/fragment'
