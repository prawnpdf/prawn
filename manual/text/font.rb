# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Fonts'

  text do
    prose <<~TEXT
      The <code>font</code> method can be used in three different ways.

      If we don't pass it any arguments it will return the current font being
      used to render text.

      If we just pass it a font name it will use that font for rendering text
      through the rest of the document.

      It can also be used by passing a font name and a block. In this case the
      specified font will only be used to render text inside the block.

      The default font is Helvetica.
    TEXT
  end

  example do
    text "Let's see which font we are using: #{font.inspect}"

    font 'Times-Roman'
    text 'Written in Times.'

    font('Courier') do
      text 'Written in Courier because we are inside the block.'
    end

    text 'Written in Times again as we left the previous block.'

    text "Let's see which font we are using again: #{font.inspect}"

    font 'Helvetica'
    text 'Back to normal.'
  end
end
