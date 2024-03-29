# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Simple Grid'

  text do
    prose <<~TEXT
      The document grid on Prawn is just a table-like structure with a defined
      number of rows and columns. There are some helpers to create boxes of
      content based on the grid coordinates.

      <code>define_grid</code> accepts the following options which are pretty
      much self-explanatory: <code>:rows</code>, <code>:columns</code>,
      <code>:gutter</code>, <code>:row_gutter</code>,
      <code>:column_gutter</code>.
    TEXT
  end

  example do
    # The grid only need to be defined once, but since all the examples should be
    # able to run alone we are repeating it on every example
    define_grid(columns: 5, rows: 8, gutter: 10)
    text 'We defined the grid, roll over to the next page to see its outline'

    start_new_page
    grid.show_all
  end
end
