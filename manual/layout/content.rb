# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Content'

  text do
    prose <<~TEXT
      Now that we know how to access the boxes we might as well add some
      content to them.

      This can be done by taping into the bounding box for a given grid box or
      multi-box with the <code>bounding_box</code> method.
    TEXT
  end

  example do
    # The grid only need to be defined once, but since all the examples should be
    # able to run alone we are repeating it on every example
    define_grid(rows: 4, columns: 5, gutter: 10)

    grid([1, 0], [3, 1]).bounding_box do
      text "Adding some content to this multi_box.\n#{' _ ' * 200}"
    end

    grid(2, 3).bounding_box do
      text "Just a little snippet here.\n#{' _ ' * 10}"
    end
  end
end
