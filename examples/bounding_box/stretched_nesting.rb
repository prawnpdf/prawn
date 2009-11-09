# encoding: utf-8
#
# This example demonstrates how nested bounding boxes work when the outer box is
# stretchy and includes several inner boxes of different sizes.

require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("stretched_nesting.pdf", :page_layout => :landscape) do

  bounding_box [100,400], :width => 500 do

    bounding_box [0, bounds.height], :width => 200, :height => 100 do
      stroke_bounds
    end

    bounding_box [200, bounds.height], :width => 150 do
      indent(5) do
        text "This box is longest, so it stretches the parent box. \n"*5
      end
    end

    bounding_box [350, bounds.height], :width => 150 do
      text "I AM SANTA CLAUS!!!"
    end

    stroke_bounds

  end

end
