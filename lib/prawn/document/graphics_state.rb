# encoding: utf-8
#
# graphics_state.rb: Implements graphics state saving and restoring
#
# Copyright January 2010, Michael Witrant. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  class Document
    module GraphicsState # @private

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
          raise PDF::Core::Errors::EmptyGraphicStateStack,
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
