# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Scaling Images'

  text do
    prose <<~TEXT
      To scale an image use the <code>:scale</code> option.

      It scales the image proportionally given the provided value.
    TEXT
  end

  example do
    text 'Normal size'
    image "#{Prawn::DATADIR}/images/stef.jpg"
    move_down 10

    text 'Scaled to 50%'
    image "#{Prawn::DATADIR}/images/stef.jpg", scale: 0.5
    move_down 10

    text 'Scaled to 200%'
    image "#{Prawn::DATADIR}/images/stef.jpg", scale: 2
  end
end
