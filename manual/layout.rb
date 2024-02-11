# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Layout')

    prose <<-TEXT
      Prawn has support for two-dimensional grid based layouts out of the box.

      The examples show:
    TEXT

    list(
      'How to define the document grid',
      'How to configure the grid rows and columns gutters',
      'How to create boxes according to the grid'
    )
  end
end
