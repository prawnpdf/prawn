# encoding: utf-8
#
# Examples for the Graphics package.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::ManualBuilder::Example.generate("graphics.pdf", :page_size => "FOLIO") do

  package "graphics" do |p|

    p.section "Basics" do |s|
      s.example "helper"
      s.example "fill_and_stroke"
    end

    p.section "Shapes" do |s|
      s.example "lines_and_curves"
      s.example "common_lines"
      s.example "rectangle"
      s.example "polygon"
      s.example "circle_and_ellipse"
    end

    p.section "Fill and Stroke settings" do |s|
      s.example "line_width"
      s.example "stroke_cap"
      s.example "stroke_join"
      s.example "stroke_dash"
      s.example "color"
      s.example "gradients"
      s.example "transparency"
      s.example "soft_masks"
      s.example "fill_rules"
    end

    p.section "Transformations" do |s|
      s.example "rotate"
      s.example "translate"
      s.example "scale"
    end

    p.intro do
      prose("Here we show all the drawing methods provided by Prawn. Use them to draw the most beautiful imaginable things.

      Most of the content that you'll add to your pdf document will use the graphics package. Even text is rendered on a page just like a rectangle so even if you never use any of the shapes described here you should at least read the basic examples.

      The examples show:")

      list( "All the possible ways that you can fill or stroke shapes on a page",
            "How to draw all the shapes that Prawn has to offer from a measly line to a mighty polygon or ellipse",
            "The configuration options for stroking lines and filling shapes",
            "How to apply transformations to your drawing space"
          )
    end

  end
end
