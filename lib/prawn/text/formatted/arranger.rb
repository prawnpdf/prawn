# encoding: utf-8

# text/formatted/arranger.rb : Implements a data structure for 2-stage
#                              processing of lines of formatted text
#
# Copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Text
    module Formatted

      class Arranger
        attr_reader :consumed
        attr_reader :unconsumed
        attr_reader :current_format_state
        attr_reader :retrieved_format_state
        attr_reader :max_line_height
        attr_reader :max_descender
        attr_reader :max_ascender
        attr_reader :last_retrieved_width

        def initialize(document)
          @document = document
          @retrieved_format_state = []
          @current_format_state = {}
          @consumed = []
        end

        def space_count
          return 0 if @consumed.empty?
          @consumed.inject(0) { |sum, hash| sum + hash[:text].count(" ") }
        end

        def line_width
          return 0 if @consumed.empty?
          @consumed.inject(0) do |sum, hash|
            sum + (hash[:width] || 0)
          end
        end

        def line
          @consumed.collect { |hash| hash[:text] }.join("")
        end

        def finalize_line
          remove_trailing_whitespace
          @consumed.each { |hash| set_size_data(hash) }
        end

        def format_array=(array)
          initialize_line
          @unconsumed = []
          array.each do |hash|
            hash[:text].scan(/[^\n]+|\n/) do |line|
              @unconsumed << hash.merge(:text => line)
            end
          end
        end

        def initialize_line
          @max_line_height = 0
          @max_descender = 0
          @max_ascender = 0
        end

        def finished?
          @unconsumed.length == 0
        end

        def unfinished?
          @unconsumed.length > 0
        end

        def next_string
          hash = @unconsumed.shift
          if hash.nil?
            nil
          else
            @consumed << hash.dup
            @current_format_state = hash.dup
            @current_format_state.delete(:text)
            hash[:text]
          end
        end

        def preview_next_string
          hash = @unconsumed.first
          if hash.nil?
            nil
          else
            hash[:text]
          end
        end

        def apply_color_and_font_settings(hash, &block)
          if hash[:rgb] || hash[:cmyk]
            original_fill_color = @document.fill_color
            original_stroke_color = @document.stroke_color
            @document.fill_color(hash[:rgb] || hash[:cmyk])
            @document.stroke_color(hash[:rgb] || hash[:cmyk])
            apply_font_settings(hash, &block)
            @document.stroke_color = original_stroke_color
            @document.fill_color = original_fill_color
          else
            apply_font_settings(hash, &block)
          end
        end

        def apply_font_settings(hash, &block)
          style = font_style(hash)
          if hash[:font] || style != :normal
            raise "Bad font family" unless @document.font.family
            @document.font(hash[:font] || @document.font.family, :style => style) do
              apply_font_size(hash, &block)
            end
          else
            apply_font_size(hash, &block)
          end
        end

        def update_last_string(printed, unprinted)
          return if printed.nil?
          if printed.empty?
            @consumed.pop
          else
            @consumed.last[:text] = printed
          end

          unless unprinted.empty?
            @unconsumed.unshift(@current_format_state.merge(:text => unprinted))
          end
        end

        def retrieve_string
          hash = @consumed.shift
          if hash.nil?
            @retrieved_format_state = nil
            @last_retrieved_width = 0
            nil
          else
            @retrieved_format_state = hash.dup
            @retrieved_format_state.delete(:text)
            @last_retrieved_width = hash[:width]
            hash[:text]
          end
        end

        def repack_unretrieved
          new_unconsumed = []
          while string = retrieve_string
            new_unconsumed << @retrieved_format_state.merge(:text => string)
          end
          @unconsumed = new_unconsumed.concat(@unconsumed)
        end

        private

        def apply_font_size(hash)
          size = hash[:size]
          if size.nil?
            yield
          else
            @document.font_size(size) { yield }
          end
        end

        def font_style(hash)
          styles = hash[:style]
          return :normal if styles.nil?
          if styles.include?(:bold) && styles.include?(:italic)
            :bold_italic
          elsif styles.include?(:bold)
            :bold
          elsif styles.include?(:italic)
            :italic
          else
            :normal
          end
        end

        def set_size_data(hash)
          apply_font_settings(hash) do
            hash[:width] = @document.width_of(hash[:text], :kerning => @kerning)
            hash[:line_height] = @document.font.height
            hash[:descender] = @document.font.descender
            hash[:ascender] = @document.font.ascender
          end
          @max_line_height = [@max_line_height, hash[:line_height]].max
          @max_descender = [@max_descender, hash[:descender]].max
          @max_ascender = [@max_ascender, hash[:ascender]].max
        end

        def remove_trailing_whitespace
          @consumed.reverse_each do |hash|
            if hash[:text] == "\n"
              break
            elsif hash[:text].strip.empty? && @consumed.length > 1
              @consumed.pop
            else
              hash[:text].rstrip!
              break
            end
          end
        end
      end

    end
  end
end
