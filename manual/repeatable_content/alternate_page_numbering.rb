# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Alternating Page Numbering'

  text do
    prose <<~TEXT
      Below is the code to generate page numbers that alternate being rendered
      on the right and left side of the page. The first page will have a "1" in
      the bottom right corner. The second page will have a "2" in the bottom
      left corner of the page. The third a "3" in the bottom right, etc.
    TEXT
  end

  example eval: false do
    text 'This is the first page!'

    10.times do
      start_new_page
      text 'Here comes yet another page.'
    end

    string = '<page>'
    odd_options = {
      at: [bounds.right - 150, 0],
      width: 150,
      align: :right,
      page_filter: :odd,
      start_count_at: 1,
    }
    even_options = {
      at: [0, bounds.left],
      width: 150,
      align: :left,
      page_filter: :even,
      start_count_at: 2,
    }
    number_pages string, odd_options
    number_pages string, even_options
  end
end
