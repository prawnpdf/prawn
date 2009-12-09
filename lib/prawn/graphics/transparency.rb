# encoding: utf-8
#
# transparency.rb : Implements transparency
#
# Copyright October 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Graphics

    # The Prawn::Transparency module is used to place transparent
    # content on the page. It has the capacity for separate
    # transparency values for stroked content and all other content.
    #
    # Example:
    #   # both the fill and stroke will be at 50% opacity
    #   pdf.transparent(0.5) do
    #     pdf.text("hello world")
    #     pdf.fill_and_stroke_circle_at([x, y], :radius => 25)
    #   end
    #
    #   # the fill will be at 50% opacity, but the stroke will
    #   # be at 75% opacity
    #   pdf.transparent(0.5, 0.75) do
    #     pdf.text("hello world")
    #     pdf.fill_and_stroke_circle_at([x, y], :radius => 25)
    #   end
    #
    module Transparency

      # Sets the <tt>opacity</tt> and <tt>stroke_opacity</tt> for all
      # the content within the <tt>block</tt>
      # If <tt>stroke_opacity</tt> is not provided, then it takes on
      # the same value as <tt>opacity</tt>
      #
      # Valid ranges for both paramters are 0.0 to 1.0
      #
      # Example:
      #   # both the fill and stroke will be at 50% opacity
      #   pdf.transparent(0.5) do
      #     pdf.text("hello world")
      #     pdf.fill_and_stroke_circle_at([x, y], :radius => 25)
      #   end
      #
      #   # the fill will be at 50% opacity, but the stroke will
      #   # be at 75% opacity
      #   pdf.transparent(0.5, 0.75) do
      #     pdf.text("hello world")
      #     pdf.fill_and_stroke_circle_at([x, y], :radius => 25)
      #   end
      #
      def transparent(opacity, stroke_opacity=opacity, &block)
        min_version(1.4)

        opacity        = [[opacity, 0.0].max, 1.0].min
        stroke_opacity = [[stroke_opacity, 0.0].max, 1.0].min

        key = "#{opacity}_#{stroke_opacity}"

        if opacity_dictionary_registry[key]
          opacity_dictionary =  opacity_dictionary_registry[key][:obj]
          opacity_dictionary_name =  opacity_dictionary_registry[key][:name]
        else
          opacity_dictionary = ref!(:Type => :ExtGState,
                                    :CA   => stroke_opacity,
                                    :ca   => opacity
                                    )

          opacity_dictionary_name = "Tr#{next_opacity_dictionary_id}"
          opacity_dictionary_registry[key] = { :name => opacity_dictionary_name, 
                                               :obj  => opacity_dictionary }
        end

        page_ext_gstates.merge!(opacity_dictionary_name => opacity_dictionary)

        # push a new graphics context onto the graphics context stack
        add_content "q"
        add_content "/#{opacity_dictionary_name} gs"

        yield if block_given?

        add_content "Q"
      end

      private

      def opacity_dictionary_registry
        @opacity_dictionary_registry ||= {}
      end

      def next_opacity_dictionary_id
        opacity_dictionary_registry.length + 1
      end

    end
  end
end
