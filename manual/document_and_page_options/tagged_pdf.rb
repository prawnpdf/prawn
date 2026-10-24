# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Tagged PDF'

  text do
    prose <<~TEXT
      A tagged PDF carries a logical structure next to its content: which text
      is a heading, which is a paragraph, which image is a figure and what it
      shows. Screen readers and other assistive technology read the document
      through it. Accessibility rules such as WCAG and PDF/UA require it.

      Pass <code>tagged: true</code> when creating the document and
      <code>language:</code> to say which language it is written in. Then wrap
      content in <code>structure</code> with a standard structure type such as
      <code>:H1</code>, <code>:P</code>, <code>:L</code> or
      <code>:Figure</code>. Structure elements nest, and an element can run
      over a page break.

      Content that is not part of the document, such as decoration, goes in
      <code>artifact</code>. Prawn already treats backgrounds, repeaters and
      page numbers as artifacts, and makes links in formatted text
      <code>:Link</code> elements.

      Every piece of content should be in one or the other. Assistive
      technology also needs embedded fonts, so use a TrueType or OpenType font
      instead of the built-in ones.
    TEXT
  end

  example eval: false, standalone: true do
    Prawn::Document.generate('example.pdf', tagged: true, language: 'en-GB') do
      font_families.update('DejaVu' => { normal: 'DejaVuSans.ttf' })
      font 'DejaVu'

      structure(:H1) { text 'Annual report', size: 20 }
      structure(:P) { text 'Paragraphs can run over page breaks.' }
      structure(:Figure, Alt: 'Revenue grew 4% in 2026') { image 'chart.png' }
      artifact(Type: :Layout) { stroke_horizontal_rule }

      structure(:L) do
        structure(:LI) { text '- First item' }
        structure(:LI) { text '- Second item' }
      end
    end
  end
end
