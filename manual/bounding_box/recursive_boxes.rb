# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Recursive Boxes'

  text do
    prose <<~TEXT
      This example is mostly just for fun, and shows how nested bounding boxes
      can simplify calculations. See the "Bounding Box" section of the manual
      for more basic uses.
    TEXT
  end

  example do
    def combine(horizontal_span, vertical_span)
      vertical_span.flat_map do |y|
        horizontal_span.zip([y] * horizontal_span.size)
      end
    end

    def recurse_bounding_box(max_depth = 4, depth = 1)
      width = (bounds.width - 15) / 2
      height = (bounds.height - 15) / 2
      left_top_corners = combine([5, bounds.right - width - 5], [bounds.top - 5, height + 5])
      left_top_corners.each do |lt|
        bounding_box(lt, width: width, height: height) do
          stroke_bounds
          recurse_bounding_box(max_depth, depth + 1) if depth < max_depth
        end
      end
    end

    recurse_bounding_box
  end
end
