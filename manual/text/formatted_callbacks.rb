# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Formatted Text Callbacks'

  text do
    prose <<~TEXT
      The <code>:callback</code> option is also available for the formatted
      text methods.

      This option accepts an object (or array of objects) on which two methods
      will be called if defined: <code>render_behind</code> and
      <code>render_in_front</code>. They are called before and after rendering
      the text fragment and are passed the fragment as an argument.

      This example defines two new callback classes and provide callback
      objects for the <code>formatted_text</code>.
    TEXT
  end

  example new_page: true do
    class HighlightCallback
      def initialize(options)
        @color, @document = options.values_at(:color, :document)
      end

      def render_behind(fragment)
        original_color = @document.fill_color
        @document.fill_color = @color
        @document.fill_rectangle(fragment.top_left, fragment.width, fragment.height)
        @document.fill_color = original_color
      end
    end

    class ConnectedBorderCallback
      def initialize(options)
        @radius, @document = options.values_at(:radius, :document)
      end

      def render_in_front(fragment)
        points = [fragment.top_left, fragment.top_right, fragment.bottom_right, fragment.bottom_left]
        @document.stroke_polygon(*points)
        points.each { |point| @document.fill_circle(point, @radius) }
      end
    end

    highlight = HighlightCallback.new(color: 'ffff00', document: self)
    border = ConnectedBorderCallback.new(radius: 2.5, document: self)

    formatted_text(
      [
        { text: 'hello', callback: highlight },
        { text: '     ' },
        { text: 'world', callback: border },
        { text: '     ' },
        { text: 'hello world', callback: [highlight, border] },
      ],
      size: 20,
    )
  end
end
