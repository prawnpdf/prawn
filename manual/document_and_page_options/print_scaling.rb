# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Print Scaling'

  text do
    prose <<~TEXT
      (Optional; PDF 1.6) The page scaling option to be selected when a print
      dialog is displayed for this document.  Valid values are
      <code>None</code>, which indicates that the print dialog should reflect
      no page scaling, and <code>AppDefault</code>, which indicates that
      applications should use the current print scaling.  If this entry has an
      unrecognized value, applications should use the current print scaling.
      Default value: <code>AppDefault</code>.

      Note: If the print dialog is suppressed and its parameters are provided
      directly by the application, the value of this entry should still be
      used.
    TEXT
  end

  example eval: false, standalone: true do
    Prawn::Document.generate(
      'example.pdf',
      page_layout: :landscape,
      print_scaling: :none,
    ) do
      text 'When you print this document, the scale to fit in print preview ' \
        'should be disabled by default.'
    end
  end
end
