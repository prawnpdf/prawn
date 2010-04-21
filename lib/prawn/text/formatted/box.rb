# encoding: utf-8

# text/formatted/rectangle.rb : Implements text boxes with formatted text
#
# Copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Text
    module Formatted

      # Draws the requested formatted text into a box. When the text overflows
      # the rectangle shrink to fit or truncate the text. Text boxes are
      # independent of the document y position.
      #
      # == Formatted Text Array
      #
      # Formatted text is comprised of an array of hashes, where each hash
      # defines text and format information. As of the time of writing, the
      # following hash options are supported:
      #
      # <tt>:text</tt>::
      #     the text to format according to the other hash options
      # <tt>:styles</tt>::
      #     an array of styles to apply to this text. Available styles include
      #     :bold, :italic, :underline, :strikethrough, :subscript, and
      #     :superscript
      # <tt>:size</tt>::
      #     an integer denoting the font size to apply to this text
      # <tt>:font</tt>::
      #     the name of a font. The name must be an AFM font with the desired
      #     faces or must be a font that is already registered using
      #     Prawn::Document#font_families
      # <tt>:color</tt>::
      #     anything compatible with Prawn::Graphics::Color#fill_color and
      #     Prawn::Graphics::Color#stroke_color
      # <tt>:link</tt>::
      #     a URL to which to create a link. A clickable link will be created
      #     to that URL. Note that you must explicitly underline and color using
      #     the appropriate tags if you which to draw attention to the link
      # <tt>:anchor</tt>::
      #     a destination that has already been or will be registered using
      #     Prawn::Core::Destinations#add_dest. A clickable link will be
      #     created to that destination. Note that you must explicitly underline
      #     and color using the appropriate tags if you which to draw attention
      #     to the link
      # <tt>:callback</tt>::
      #     a hash with the following options
      #     <tt>:object</tt>:: required. the object to target
      #     <tt>:method</tt>:: required. the method to call on the target object
      #     <tt>:arguments</tt>:: optional. the arguments to pass to the
      #         callback method
      #
      # == Example
      #
      #   formatted_text_box([{ :text => "hello" },
      #                       { :text => "world",
      #                         :size => 24,
      #                         :styles => [:bold, :italic] }])
      #
      # == Options
      #
      # Accepts the same options as Text::Box with the below exceptions
      #
      # <tt>:overflow</tt>::
      #     does not accept :ellipses
      #
      # == Returns
      #
      # Returns a formatted text array representing any text that did not print
      # under the current settings.
      #
      # == Exceptions
      #
      # Raises "Bad font family" if no font family is defined for the current font
      #
      # Raises <tt>Prawn::Errrors::CannotFit</tt> if not wide enough to print
      # any text
      #
      # Raises <tt>NotImplementedError</tt> if <tt>:ellipses</tt> <tt>overflow</tt>
      # option included
      #
      def formatted_text_box(array, options)
        Text::Formatted::Box.new(array, options.merge(:document => self)).render
      end

      # Generally, one would use the Prawn::Text::Formatted#formatted_text_box
      # convenience method. However, using Text::Formatted::Box.new in
      # conjunction with #render(:dry_run => true) enables one to do look-ahead
      # calculations prior to placing text on the page, or to determine how much
      # vertical space was consumed by the printed text
      #
      class Box < Prawn::Text::Box
        include Prawn::Core::Text::Formatted::Wrap

        def initialize(array, options={})
          super(array, options)
          if @overflow == :ellipses
            raise NotImplementedError, "ellipses overflow unavailable with" +
              "formatted box"
          end
        end

        # The height actually used during the previous <tt>render</tt>
        # 
        def height
          return 0 if @baseline_y.nil? || @descender.nil?
          @baseline_y.abs + @line_height - @ascender
        end

        # <tt>fragment</tt> is a Prawn::Text::Formatted::Fragment object
        #
        def draw_fragment(fragment, accumulated_width=0, line_width=0, word_spacing=0) #:nodoc:
          case(@align)
          when :left, :justify
            x = @at[0]
          when :center
            x = @at[0] + @width * 0.5 - line_width * 0.5
          when :right
            x = @at[0] + @width - line_width
          end

          x += accumulated_width

          y = @at[1] + @baseline_y

          y += fragment.y_offset

          fragment.left = x
          fragment.baseline = y

          if @inked
            if @align == :justify
              @document.word_spacing(word_spacing) {
                @document.draw_text!(fragment.text, :at => [x, y],
                                     :kerning => @kerning)
              }
            else
              @document.draw_text!(fragment.text, :at => [x, y],
                                   :kerning => @kerning)
            end

            draw_fragment_overlays(fragment)
          end
        end

        private

        def original_text
          @original_array.collect { |hash| hash.dup }
        end

        def original_text=(array)
          @original_array = array
        end

        def normalize_encoding
          array = original_text
          array.each do |hash|
            hash[:text] = @document.font.normalize_encoding(hash[:text])
          end
          array
        end

        def move_baseline_down
          if @baseline_y == 0
            @baseline_y  = -@ascender
          else
            @baseline_y -= (@line_height + @leading)
          end
        end

        def draw_fragment_overlays(fragment)
          draw_fragment_overlay_styles(fragment)
          draw_fragment_overlay_link(fragment)
          draw_fragment_overlay_anchor(fragment)
        end

        def draw_fragment_overlay_link(fragment)
          return unless fragment.link
          box = fragment.absolute_bounding_box
          @document.link_annotation(box,
                                    :Border => [0, 0, 0],
                                    :A => { :Type => :Action,
                                            :S => :URI,
                          :URI => Prawn::Core::LiteralString.new(fragment.link) })
        end

        def draw_fragment_overlay_anchor(fragment)
          return unless fragment.anchor
          box = fragment.absolute_bounding_box
          @document.link_annotation(box,
                                    :Border => [0, 0, 0],
                                    :Dest => fragment.anchor)
        end

        def draw_fragment_overlay_styles(fragment)
          underline = fragment.styles.include?(:underline)
          if underline
            @document.stroke_line(fragment.underline_points)
          end
          
          strikethrough = fragment.styles.include?(:strikethrough)
          if strikethrough
            @document.stroke_line(fragment.strikethrough_points)
          end
        end

      end

    end
  end
end
