# encoding: utf-8
#
# Demonstrates transformations
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

pdf = Prawn::Document.generate "transformations.pdf", :margin => 0 do
  line_width = 0.1
  def draw_origin
    stroke_color "#00FF00"
    size = 2
    stroke_line -size, 0, size, 0
    stroke_line 0, -size, 0, size
  end
  
  def draw(name)
    stroke_color "#000000"
    fill { rectangle([0, 0], 20, 50) }
    text name, :at => [21, -50]
  end
  
  translate *bounds.top_left
  translate 10, -10
  draw "base"
  draw_origin
  
  translate 100, 0 do
    rotate 10 do
      draw "10° rotation"
    end
    draw_origin

    translate 100, 0
    skew 10, 10 do
      draw "skew(10, 10)"
    end
    draw_origin

    translate 100, 0
    skew -10, -10 do
      draw "skew(-10, -10)"
    end
    draw_origin
  end

  translate 0, -100
  save_graphics_state do
    scale 0.7 do
      draw "scale(0.7)"
    end
    draw_origin

    translate 100, 0
    save_graphics_state do
      rotate 30
      scale 0.7
      draw "rotate and scale"
    end
    draw_origin

    translate 100, 0
    save_graphics_state do
      scale 0.7
      rotate 30
      draw "scale and rotate"
    end
    draw_origin
  end

  translate 0, -100
  save_graphics_state do
    scale 0.7
    save_graphics_state do
      translate 10, 0
      rotate 60
      draw "translate and rotate"
    end
    draw_origin

    translate 100, 0
    save_graphics_state do
      rotate 60
      translate 10, 0
      draw "rotate and translate"
    end
    draw_origin

  end
end
