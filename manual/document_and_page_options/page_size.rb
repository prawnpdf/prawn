# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Page Size'

  text do
    prose <<~TEXT
      Prawn comes with support for most of the common page sizes so you'll only
      need to provide specific values if your intended format is not supported.
      To see a list with all supported sizes take a look at
      <code>PDF::Core::PageGeometry</code>.

      To define the size use <code>:page_size</code> when creating new
      documents and <code>:size</code> when starting new pages. The default
      page size for new documents is LETTER (612.00 x 792.00).

      You may also define the orientation of the page to be either portrait
      (default) or landscape. Use <code>:page_layout</code> when creating new
      documents and <code>:layout</code> when starting new pages.
    TEXT
  end

  example eval: false, standalone: true do
    Prawn::Document.generate(
      'example.pdf',
      page_size: 'EXECUTIVE',
      page_layout: :landscape,
    ) do
      text 'EXECUTIVE landscape page.'

      custom_size = [275, 326]

      ['A4', 'TABLOID', 'B7', custom_size].each do |size|
        start_new_page(size: size, layout: :portrait)
        text "#{size} portrait page."

        start_new_page(size: size, layout: :landscape)
        text "#{size} landscape page."
      end
    end
  end
end
