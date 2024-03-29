# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Absolute Positioning'

  text do
    prose <<~TEXT
      One of the options that the <code>image</code> method accepts is
      <code>:at</code>. If you've read some of the graphics examples you are
      probably already familiar with it. Just provide it the upper-left corner
      where you want the image placed.

      While sometimes useful this option won't be practical. Notice that the
      cursor won't be moved after the image is rendered and there is nothing
      forbidding the text to overlap with the image.
    TEXT
  end

  example do
    y_position = cursor
    text "The image won't go below this line of text."

    image "#{Prawn::DATADIR}/images/fractal.jpg", at: [200, y_position]

    text 'And this line of text will go just below the previous one.'
  end
end
