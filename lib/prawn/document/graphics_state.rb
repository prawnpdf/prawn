# encoding: utf-8
#
# graphics_state.rb: Implements graphics state saving and restoring
#
# Copyright January 2010, Michael Witrant. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
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
        raise Prawn::Errors::EmptyGraphicStateStack, 
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
      "[#{@dash[:dash]} #{@dash[:space]}] #{@dash[:phase]} d"
    end
  end
  
  module Core
    class Page
      module GraphicsState
      
        def graphic_state
          stack.current_state
        end
    
      end
    end
  end
  
  class Document
    module GraphicsState

      # Pushes the current graphics state on to the graphics state stack so we
      # can restore it when finished with a change we want to isolate (such as
      # modifying the transformation matrix). Used in pairs with
      # restore_graphics_state or passed a block
      #
      # Example without a block:
      #
      #   save_graphics_state
      #   rotate 30
      #   text "rotated text"
      #   restore_graphics_state
      #
      # Example with a block:
      #
      #   save_graphics_state do
      #     rotate 30
      #     text "rotated text"
      #   end
      #
      
      def open_graphics_state
        add_content "q"
      end
      
      def close_graphics_state
        add_content "Q"
      end
        
      def save_graphics_state(graphic_state = nil)
        graphic_stack.save_graphic_state(graphic_state)
        open_graphics_state
        if block_given?
          yield
          restore_graphics_state
        end
      end

      # Pops the last saved graphics state off the graphics state stack and
      # restores the state to those values
      def restore_graphics_state
        if graphic_stack.empty?
          raise Prawn::Errors::EmptyGraphicStateStack, 
            "\n You have reached the end of the graphic state stack" 
        end
        close_graphics_state 
        graphic_stack.restore_graphic_state
      end
      
      def graphic_stack
        state.page.stack
      end
      
      def graphic_state
        save_graphics_state unless graphic_stack.current_state
        graphic_stack.current_state 
      end
      
    end
  end
end
