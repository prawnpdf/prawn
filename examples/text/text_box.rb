# encoding: utf-8
#

require 'examples/example_helper'

Prawn::Document.generate("text_box.pdf") do
  def get_string(i, j)      
    case i
    when 0
      text = "this is left text " * 30
      text.insert(48, "\n\n")
    when 1
      text = "this is center text " * 30
      text.insert(54, "\n\n")
    when 2
      text = "this is right text " * 30
      text.insert(51, "\n\n")
    end
    
    case j
    when 0
      text.split(" ").slice(0..47).join(" ")
    when 3
      text.delete(" ")
    else
      text
    end
  end

  def get_options(i, j)
    options = {
      :width    => bounds.width * 0.3,
      :height   => bounds.width * 0.3,
      :overflow => :ellipses,
      :at       => [0, 0],
      :align    => :left,
      :document => self
    }
    
    case i
    when 0
      options[:valign] = :top if j == 0
    when 1
      options[:align] = :center
      options[:valign] = :center if j == 0
    when 2
      options[:align] = :right
      options[:valign] = :bottom if j == 0
    end
    
    case j
    when 1
      options[:overflow] = :shrink_to_fit
    when 2
      options[:leading] = font.height * 0.5
      options[:overflow] = :truncate
    end
    options
  end

  stroke_color("555555")
  3.times do |i|
    4.times do |j|
      options = get_options(i, j)
      options[:at][0] = (bounds.width  - options[:width]) * 0.5 * i
      options[:at][1] = bounds.top - (bounds.height - options[:height]) * 0.33 * j
      box = Prawn::Text::Box.new(get_string(i, j), options)

      fill_color("ffeeee")
      if i == 1
        # bound with a box of a particular size, regardless of how
        # much text it contains
        fill_and_stroke_rectangle(options[:at],
                                  options[:width],
                                  options[:height])
      else
        # bound with a box that exactly fits the printed text using
        # dry_run look-ahead
        box.render(:dry_run => true)
        fill_and_stroke_rectangle(options[:at],
                                  options[:width],
                                  box.height)
      end
      fill_color("000000")
      box.render
    end
  end
end
