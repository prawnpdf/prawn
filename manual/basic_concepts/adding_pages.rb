# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Adding Pages'

  text do
    prose <<~TEXT
      A PDF document is a collection of pages. When we create a new document be
      it with <code>Document.new</code> or on a <code>Document.generate</code>
      block one initial page is created for us.

      Some methods might create new pages automatically like <code>text</code>
      which will create a new page whenever the text string cannot fit on the
      current page.

      But what if you want to go to the next page by yourself? That is easy.

      Just use the <code>start_new_page</code> method and a shiny new page will
      be created for you just like in the following snippet.
    TEXT
  end

  example do
    text "We are still on the initial page for this example. Now I'll ask " \
      'Prawn to gently start a new page. Please follow me to the next page.'

    start_new_page

    text "See. We've left the previous page behind."
  end
end
