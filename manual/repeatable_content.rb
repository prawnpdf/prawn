# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Repeatable Content')

    prose <<-TEXT
      Prawn offers two ways to handle repeatable content blocks. Repeater is
      useful for content that gets repeated at well defined intervals while
      Stamp is more appropriate if you need better control of when to repeat
      it.

      There is also one very specific helper for numbering pages.

      The examples show:
    TEXT

    list(
      'How to repeat content on several pages with a single invocation',
      'How to create a new Stamp',
      'How to "stamp" the content block on the page',
      'How to number the document pages with one simple call'
    )
  end
end
