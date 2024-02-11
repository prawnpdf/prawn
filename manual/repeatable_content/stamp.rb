# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Stamp'

  text do
    prose <<~TEXT
      Stamps should be used when you have content that will be included
      multiple times in a document. Its advantages over creating the content
      anew each time are:
    TEXT

    ordered_list(
      'Faster document creation',
      'Smaller final document',
      'Faster display on subsequent displays of the repeated element because '\
        'the viewer application can cache the rendered results'
    )

    prose <<~TEXT
      The <code>create_stamp</code> method does just what it says. Pass it a
      block with the content that should be generated and the stamp will be
      created.

      There are two methods to render the stamp on a page <code>stamp</code>
      and <code>stamp_at</code>. The first will render the stamp as is while
      the second accepts a point to serve as an offset to the stamp content.
    TEXT
  end

  example do
    create_stamp('approved') do
      rotate(30, origin: [-5, -5]) do
        stroke_color 'FF3333'
        stroke_ellipse [0, 0], 29, 15
        stroke_color '000000'

        fill_color '993333'
        font('Times-Roman') do
          draw_text 'Approved', at: [-23, -3]
        end
        fill_color '000000'
      end
    end

    stamp 'approved'

    stamp_at 'approved', [200, 100]
  end
end
