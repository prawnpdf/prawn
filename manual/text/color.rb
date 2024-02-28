# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Color'

  text do
    prose <<~TEXT
      The <code>:color</code> attribute can give a block of text a default
      color, in RGB hex format or 4-value CMYK.
    TEXT
  end

  example do
    text 'Default color is black'
    move_down 25

    text 'Changed to red', color: 'FF0000'
    move_down 25

    text 'CMYK color', color: [22, 55, 79, 30]
    move_down 25

    text(
      "Also works with <color rgb='ff0000'>inline</color> formatting",
      color: '0000FF',
      inline_format: true,
    )
  end
end
