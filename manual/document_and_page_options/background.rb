# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Background'

  text do
    prose <<~TEXT
      Pass an image path to the <code>:background</code> option and it will be
      used as the background for all pages.

      This option can only be used on document creation.
    TEXT
  end

  example eval: false, standalone: true do
    img = "#{Prawn::DATADIR}/images/letterhead.jpg"

    Prawn::Document.generate('example.pdf', background: img, margin: 100) do
      text 'My report caption', size: 18, align: :right

      move_down font.height * 2

      text 'Here is my text explaining this report. ' * 20,
        size: 12,
        align: :left,
        leading: 2

      move_down font.height

      text "I'm using a soft background. " * 40,
        size: 12,
        align: :left,
        leading: 2
    end
  end
end
