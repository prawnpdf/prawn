# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Prawn::Table'

  text do
    prose <<~TEXT
      As of Prawn 1.2.0, Prawn::Table has been extracted into its own
      semi-officially supported gem.

      Please see https://github.com/prawnpdf/prawn-table for more details.
    TEXT
  end
end
