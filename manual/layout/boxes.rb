# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Boxes'

  text do
    prose <<~TEXT
      After defined the grid is there but nothing happens. To start taking
      effect we need to use the grid boxes.

      <code>grid</code> has three different return values based on the
      arguments received. With no arguments it will return the grid itself.
      With integers it will return the grid box at those indices. With two
      arrays it will return a multi-box spanning the region of the two grid
      boxes at the arrays indices.
    TEXT
  end

  example do
    # The grid only need to be defined once, but since all the examples should be
    # able to run alone we are repeating it on every example
    define_grid(columns: 5, rows: 4, gutter: 10)

    grid(0, 0).show
    grid(1, 1).show

    grid([2, 2], [3, 3]).show

    grid([0, 4], [3, 4]).show
    grid([3, 0], [3, 1]).show
  end
end
