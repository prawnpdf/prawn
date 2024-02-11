# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'UTF-8'

  text do
    prose <<~TEXT
      Multilingualization isn't much of a problem on Prawn as its default
      encoding is UTF-8. The only thing you need to worry about is if the font
      support the glyphs of your language.
    TEXT
  end

  example do
    text 'Take this example, a simple Euro sign:'
    text '€', size: 32
    move_down 20

    text 'This works, because €  is one of the few ' \
      'non-ASCII glyphs supported in PDF built-in fonts.'

    move_down 20

    text 'For full internationalized text support, we need to use external fonts:'
    move_down 20

    font("#{Prawn::ManualBuilder::DATADIR}/fonts/DejaVuSans.ttf") do
      text 'ὕαλον ϕαγεῖν δύναμαι· τοῦτο οὔ με βλάπτει.'
      text 'There you go.'
    end
  end
end
