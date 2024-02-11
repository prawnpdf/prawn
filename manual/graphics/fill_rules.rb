# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Fill Rules'

  text do
    prose <<~TEXT
      Prawn's fill operators (<code>fill</code> and
      <code>fill_and_stroke</code> both accept a <code>:fill_rule</code>
      option. These rules determine which parts of the page are counted as
      "inside" vs. "outside" the path. There are two fill rules:
    TEXT

    list(
      '<code>:nonzero_winding_number</code> (default): a point is inside the '\
        'path if a ray from that point to infinity crosses a nonzero "net '\
        'number" of path segments, where path segments intersecting in one '\
        'direction are counted as positive and those in the other direction '\
        'negative.',
      '<code>:even_odd</code>: A point is inside the path if a ray from that '\
        'point to infinity crosses an odd number of path segments, regardless '\
        'of direction.'
    )

    prose <<~TEXT
      The differences between the fill rules only come into play with complex
      paths; they are identical for simple shapes.
    TEXT
  end

  example axes: true do
    pentagram = [[181, 95], [0, 36], [111, 190], [111, 0], [0, 154]]

    stroke_color 'ff0000'
    line_width 2

    text_box 'Nonzero Winding Number', at: [10, 200]
    polygon(*pentagram.map { |x, y| [x + 50, y] })
    fill_and_stroke

    text_box 'Even-Odd', at: [330, 200]
    polygon(*pentagram.map { |x, y| [x + 330, y] })
    fill_and_stroke(fill_rule: :even_odd)
  end
end
