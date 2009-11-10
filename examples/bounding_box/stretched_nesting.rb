# encoding: utf-8
#
# This example demonstrates how nested bounding boxes work when the outer box is
# stretchy and includes several inner boxes of different sizes.

require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("stretched_nesting.pdf", :page_layout => :landscape) do

  def stroke_dashed_bounds
    dash(1)
    stroke_bounds
    undash
  end

  bounding_box [100,400], :width => 500 do

    bounding_box [0, bounds.top], :width => 200, :height => 100 do
      stroke_bounds
    end

    bounding_box [200, bounds.top], :width => 150 do
      indent(5) do
        text "This box is longest, so it stretches the parent box. \n"*5
      end
    end

    bounding_box [350, bounds.top], :width => 150 do
      text "I AM SANTA CLAUS!!!"
    end

    stroke_dashed_bounds

  end

  bounding_box [100, 250], :width => 500 do

    bounding_box [0, bounds.top], :width => 100, :height => 100 do
      text "1"
      stroke_bounds
    end

    bounding_box [125, bounds.top], :width => 50, :height => 25 do
      text "2"
      stroke_bounds
    end

    bounding_box [200, bounds.top - 50], :width => 50, :height => 125 do
      text "3"
      stroke_bounds
    end

    bounding_box [350, bounds.top - 100], :width => 20, :height => 20 do
      text "4"
      stroke_bounds
    end

    bounding_box [400, bounds.height - 150], :width => 100, :height => 100 do
      text "5"
      stroke_bounds
    end

    stroke_dashed_bounds

  end

end
