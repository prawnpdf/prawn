# encoding: utf-8
#

require 'examples/example_helper'

Prawn::Document.generate("text_box.pdf") do
  bounds_h_middle = (bounds.left + bounds.right) * 0.5
  bounds_v_middle = (bounds.bottom + bounds.top) * 0.5
  base_options = {
                  :width    => bounds.width * 0.3,
                  :height   => bounds.width * 0.3,
                  :overflow => :ellipses,
                  :at       => [0, 0],
                  :align    => :left,
                 }
  3.times do |i|
    4.times do |j|
      options = base_options.clone
      
      case i
      when 0
        text = "this is left text " * 30
        text.insert(48, "\n\n")
        options[:vertical_align] = :top if j == 0
      when 1
        text = "this is center text " * 30
        text.insert(54, "\n\n")
        options[:align] = :center
        options[:vertical_align] = :center if j == 0
      when 2
        text = "this is right text " * 30
        text.insert(51, "\n\n")
        options[:align] = :right
        options[:vertical_align] = :bottom if j == 0
      end
      
      case j
      when 0
        text = text.split(" ").slice(0..47).join(" ")
      when 1
        options[:overflow] = :shrink_to_fit
      when 2
        options[:leading] = font.height * 0.5
        options[:overflow] = :truncate
      when 3
        text.delete!(" ")
      end

      coords = options[:at]
      coords[0] = bounds.left + (bounds.width  - options[:width]) * 0.5 * i
      coords[1] = bounds.top - (bounds.height - options[:height]) * 0.33 * j
      
      stroke_color("555555")
      stroke_rectangle(coords, options[:width], options[:height])
      
      text_box(text, options)
    end
  end
end
