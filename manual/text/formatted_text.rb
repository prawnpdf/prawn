# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Formatted Text'

  text do
    prose <<~TEXT
      There are two other text methods available: <code>formatted_text</code>
      and <code>formatted_text_box</code>.

      These are useful when the provided text has numerous portions that need
      to be formatted differently. As you might imply from their names the
      first should be used for free flowing text just like the
      <code>text</code> method and the last should be used for positioned text
      just like <code>text_box</code>.

      The main difference between these methods and the <code>text</code> and
      <code>text_box</code> methods is how the text is provided. The
      <code>formatted_text</code> and <code>formatted_text_box</code> methods
      accept an array of hashes. Each hash must provide a <code>:text</code>
      option which is the text string and may provide the following options:
      <code>:styles</code> (an array of symbols), <code>:size</code> (the font
      size), <code>:character_spacing</code> (additional space between the
      characters), <code>:font</code> (the name of a registered font),
      <code>:color</code> (the same input accepted by <code>fill_color</code>
      and <code>stroke_color</code>), <code>:link</code> (an URL to create a
      link), and <code>:local</code> (a link to a local file).
    TEXT
  end

  example new_page: true do
    formatted_text [
      { text: 'Some bold. ', styles: [:bold] },
      { text: 'Some italic. ', styles: [:italic] },
      { text: 'Bold italic. ', styles: %i[bold italic] },
      { text: 'Bigger Text. ', size: 20 },
      { text: 'More spacing. ', character_spacing: 3 },
      { text: 'Different Font. ', font: 'Courier' },
      { text: 'Some coloring. ', color: 'FF00FF' },
      { text: 'Link to the home page. ', color: '0000FF', link: 'https://prawnpdf.org/' },
      { text: 'Link to a local file. ', color: '0000FF', local: 'README.md' }
    ]

    formatted_text_box(
      [
        { text: 'Just your regular' },
        { text: ' text_box ', font: 'Courier' },
        {
          text: 'with some additional formatting options added to the mix.',
          color: [50, 100, 0, 0],
          styles: [:italic]
        }
      ],
      at: [100, 100],
      width: 200,
      height: 100
    )
  end
end
