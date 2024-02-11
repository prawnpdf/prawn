# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Font Style'

  text do
    prose <<~TEXT
      Most font families come with some styles other than normal. Most common
      are <code>bold</code>, <code>italic</code> and <code>bold_italic</code>.

      The style can be set the using the <code>:style</code> option, with
      either the <code>font</code> method which will set the font and style for
      rest of the document, or with the inline text methods.
    TEXT
  end

  example do
    fonts = %w[Courier Helvetica Times-Roman]
    styles = %i[bold bold_italic italic normal]

    fonts.each do |example_font|
      move_down 20

      styles.each do |style|
        font example_font, style: style
        text "I'm writing in #{example_font} (#{style})"
      end
    end
  end
end
