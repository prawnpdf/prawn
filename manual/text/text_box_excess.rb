# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Text Box Excess'

  text do
    prose <<~TEXT
      Whenever the <code>text_box</code> method truncates text, this truncated
      bit is not lost, it is the method return value and we can take advantage
      of that.

      We just need to take some precautions.

      This example renders as much of the text as will fit in a larger font
      inside one text_box and then proceeds to render the remaining text in the
      default size in a second text_box.
    TEXT
  end

  example do
    string = 'This is the beginning of the text. It will be cut somewhere and ' \
      'the rest of the text will proceed to be rendered this time by ' \
      'calling another method.' + ' . ' * 50

    y_position = cursor - 20
    excess_text = text_box(
      string,
      width: 300,
      height: 50,
      overflow: :truncate,
      at: [100, y_position],
      size: 18
    )

    text_box(
      excess_text,
      width: 300,
      at: [100, y_position - 100]
    )
  end
end
