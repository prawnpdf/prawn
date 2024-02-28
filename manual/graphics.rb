# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Graphics')

    prose <<-TEXT
      Here we show all the drawing methods provided by Prawn. Use them to draw
      the most beautiful imaginable things.

      Most of the content that you'll add to your pdf document will use the
      graphics package. Even text is rendered on a page just like a rectangle
      so even if you never use any of the shapes described here you should at
      least read the basic examples.

      The examples show:
    TEXT

    list(
      'All the possible ways that you can fill or stroke shapes on a page',
      'How to draw all the shapes that Prawn has to offer from a measly ' \
        'line to a mighty polygon or ellipse',
      'The configuration options for stroking lines and filling shapes',
      'How to apply transformations to your drawing space',
    )
  end
end
