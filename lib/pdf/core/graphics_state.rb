# encoding: utf-8
#
# Implements graphics state saving and restoring
#
# Copyright January 2010, Michael Witrant. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details
#


module PDF
  module Core
    class GraphicStateStack
      attr_accessor :stack

      def initialize(previous_state = nil)
        self.stack = [GraphicState.new(previous_state)]
      end

      def save_graphic_state(graphic_state = nil)
        stack.push(GraphicState.new(graphic_state || current_state))
      end

      def restore_graphic_state
        if stack.empty?
          raise PDF::Core::Errors::EmptyGraphicStateStack,
            "\n You have reached the end of the graphic state stack"
        end
        stack.pop
      end

      def current_state
        stack.last
      end

      def present?
        stack.size > 0
      end

      def empty?
        stack.empty?
      end

    end

    class GraphicState
      attr_accessor :color_space, :dash, :cap_style, :join_style, :line_width, :fill_color, :stroke_color

      def initialize(previous_state = nil)
        @color_space = previous_state ? previous_state.color_space.dup : {}
        @fill_color = previous_state ? previous_state.fill_color : "000000"
        @stroke_color = previous_state ? previous_state.stroke_color : "000000"
        @dash = previous_state ? previous_state.dash : { :dash => nil, :space => nil, :phase => 0 }
        @cap_style = previous_state ? previous_state.cap_style : :butt
        @join_style = previous_state ? previous_state.join_style : :miter
        @line_width = previous_state ? previous_state.line_width : 1
      end

      def dash_setting
        if @dash[:dash].kind_of?(Array)
          "[#{@dash[:dash].join(' ')}] #{@dash[:phase]} d"
        else
          "[#{@dash[:dash]} #{@dash[:space]}] #{@dash[:phase]} d"
        end
      end
    end
  end
end
