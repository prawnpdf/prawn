# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Bounding Box')

    prose <<-TEXT
      Bounding boxes are the basic containers for structuring the content
      flow. Even being low level building blocks sometimes their simplicity is
      very welcome.

      The examples show:
    TEXT

    list(
      'How to create bounding boxes with specific dimensions',
      'How to inspect the current bounding box for its coordinates',
      'Stretchy bounding boxes',
      'Nested bounding boxes',
      'Indent blocks'
    )
  end
end
