# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Outline')

    prose <<-TEXT
      The outline of a PDF document is the table of contents tab you see to
      the right or left of your PDF viewer.

      The examples include:
    TEXT

    list(
      'How to define sections and pages',
      'How to insert sections and/or pages to a previously defined outline structure',
    )
  end
end
