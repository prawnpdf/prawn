# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Registering Font Families'

  text do
    prose <<~TEXT
      Registering font families will help you when you want to use a font over
      and over or if you would like to take advantage of the <code>:style</code>
      option of the text methods and the <code>b</code> and <code>i</code> tags
      when using inline formatting.

      To register a font family update the <code>font_families</code> hash with
      the font path for each style you want to use.
    TEXT
  end

  example new_page: true do
    # Registering a single external font
    font_families.update(
      'DejaVu Sans' => {
        normal: "#{Prawn::ManualBuilder::DATADIR}/fonts/DejaVuSans.ttf",
      },
    )

    font('DejaVu Sans') do
      text 'Using the DejaVu Sans font providing only its name to the font method'
    end
    move_down 20

    # Registering a DFONT package
    font_path = "#{Prawn::ManualBuilder::DATADIR}/fonts/Panic+Sans.dfont"
    font_families.update(
      'Panic Sans' => {
        normal: { file: font_path, font: 'PanicSans' },
        italic: { file: font_path, font: 'PanicSans-Italic' },
        bold: { file: font_path, font: 'PanicSans-Bold' },
        bold_italic: { file: font_path, font: 'PanicSans-BoldItalic' },
      },
    )

    font 'Panic Sans'
    text 'Also using Panic Sans by providing only its name'
    move_down 20

    text 'Taking <b>advantage</b> of the <i>inline formatting</i>',
      inline_format: true
    move_down 20

    %i[bold bold_italic italic normal].each do |style|
      text "Using the #{style} style option.", style: style
      move_down 10
    end
  end
end
