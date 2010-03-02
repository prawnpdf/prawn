# encoding: utf-8

# text/formatted/fragment.rb : Implements information about a formatted fragment
#
# Copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Text
    module Formatted
      class Fragment

        attr_reader :text, :format_state
        attr_writer :width
        attr_accessor :line_height, :descender, :ascender

        def initialize(text, format_state, document)
          @text = text
          @format_state = format_state
          @document = document
        end

        def width(options={})
          if options[:word_spacing].nil? then @width
          else @width + options[:word_spacing] * @text.count(" ")
          end
        end

        def subscript?
          styles.include?(:subscript)
        end

        def superscript?
          styles.include?(:superscript)
        end

        def y_offset
          if subscript? then -descender
          elsif superscript? then 0.85 * ascender
          else 0
          end
        end

        def bounding_box(left, baseline, options={})
          [left, baseline - descender, left + width(options), baseline + ascender]
        end

        def absolute_bounding_box(left, baseline, options={})
          box = bounding_box(left, baseline, options)
          box[0] += @document.bounds.absolute_left
          box[2] += @document.bounds.absolute_left
          box[1] += @document.bounds.absolute_bottom
          box[3] += @document.bounds.absolute_bottom
          box
        end

        def underline_points(left, baseline, options={})
          box = bounding_box(left, baseline, options)
          y = baseline - 1.25
          [[box[0], y], [box[2], y]]
        end

        def strikethrough_points(left, baseline, options={})
          box = bounding_box(left, baseline, options)
          y = baseline + ascender * 0.3
          [[box[0], y], [box[2], y]]
        end

        def styles
          @format_state[:styles] || []
        end

        def link
          @format_state[:link]
        end

        def anchor
          @format_state[:anchor]
        end

        def color
          @format_state[:color]
        end

        def font
          @format_state[:font]
        end

        def size
          @format_state[:size]
        end
        
      end
    end
  end
end
