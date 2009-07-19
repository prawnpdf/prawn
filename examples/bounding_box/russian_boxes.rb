# encoding: utf-8
#
# This example is mostly just for fun, and shows how nested bounding boxes
# can simplify calculations.  See the other files in examples/bounding_box
# for more basic uses.

require "#{File.dirname(__FILE__)}/../example_helper.rb"

class Array
  def combine(arr)
    output = []
    self.each do |i1|
      arr.each do |i2|
        output += [[i1,i2]]
      end
    end
    output
  end
end

def recurse_bounding_box(pdf, max_depth=5, depth=1)
  box = pdf.bounds
  width = (box.width-15)/2
  height = (box.height-15)/2
  left_top_corners = [5, box.right-width-5].combine [box.top-5, height+5]
  left_top_corners.each do |lt|
    pdf.bounding_box(lt, :width=>width, :height=>height) do
      pdf.stroke_bounds
      recurse_bounding_box(pdf, max_depth, depth+1) if depth<max_depth
    end
  end
end

Prawn::Document.generate("russian_boxes.pdf") do |pdf|
  recurse_bounding_box(pdf)
end