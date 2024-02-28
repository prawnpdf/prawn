# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Fallback Fonts'

  text do
    prose <<~TEXT
      Prawn enables the declaration of fallback fonts for those glyphs that may
      not be present in the desired font. Use the <code>:fallback_fonts</code>
      option with any of the text or text box methods, or set fallback_fonts
      document-wide.
    TEXT
  end

  example do
    jigmo_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/Jigmo.ttf"
    font_families['Jigmo'] = { normal: { file: jigmo_file, font: 'Jigmo' } }
    panic_sans_file = "#{Prawn::ManualBuilder::DATADIR}/fonts/Panic+Sans.dfont"
    font_families['Panic Sans'] = { normal: { file: panic_sans_file, font: 'PanicSans' } }

    font('Panic Sans') do
      text(
        'When fallback fonts are included, each glyph will be rendered ' \
          'using the first font that includes the glyph, starting with the ' \
          'current font and then moving through the fallback fonts from left ' \
          'to right.' \
          "\n\n" \
          "hello ƒ 你好\n再见 ƒ goodbye",
        fallback_fonts: %w[Times-Roman Jigmo],
      )
    end
    move_down 20

    formatted_text(
      [
        { text: 'Fallback fonts can even override' },
        { text: 'fragment fonts (你好)', font: 'Times-Roman' },
      ],
      fallback_fonts: %w[Times-Roman Jigmo],
    )
  end
end
