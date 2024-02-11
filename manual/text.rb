# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Text')

    prose <<-TEXT
      This is probably the feature people will use the most. There is no
      shortage of options when it comes to text. You'll be hard pressed to
      find a use case that is not covered by one of the text methods and
      configurable options.

      The examples show:
    TEXT

    list(
      'Text that flows from page to page automatically starting new pages when necessary',
      'How to use text boxes and place them on specific positions',
      'What to do when a text box is too small to fit its content',
      'Flowing text in columns',
      'How to change the text style configuring font, size, alignment and many other settings',
      'How to style specific portions of a text with inline styling and formatted text',
      'How to define formatted callbacks to reuse common styling definitions',
      'How to use the different rendering modes available for the text methods',
      'How to create your custom text box extensions',
      'How to use external fonts on your pdfs',
      'What happens when rendering text in different languages'
    )
  end
end
