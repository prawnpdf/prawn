# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Polygons'

  text do
    prose <<~TEXT
      Drawing polygons in Prawn is easy, just pass a sequence of points to one
      of the polygon family of methods.

      Just like <code>rounded_rectangle</code> we also have
      <code>rounded_polygon</code>. The only difference is the radius param
      comes before the polygon points.
    TEXT
  end

  example axes: true do
    # Triangle
    stroke_polygon [50, 200], [50, 300], [150, 300]

    # Hexagon
    fill_polygon [50, 150], [150, 200], [250, 150], [250, 50], [150, 0], [50, 50]

    # Pentagram
    pentagon_points = [500, 100], [430, 5], [319, 41], [319, 159], [430, 195]
    pentagram_points = [0, 2, 4, 1, 3].map { |i| pentagon_points[i] }

    stroke_rounded_polygon(20, *pentagram_points)
  end
end
