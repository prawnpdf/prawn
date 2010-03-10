# encoding: utf-8
#

require 'examples/example_helper'

Prawn::Document.generate("hyphenation.pdf") do
  def get_string(i)
    case i
    when 0
      text = "this­is­soft­hyphenated­text­" * 30
    when 1
      text = "this-is-hard-hyphenated-text-" * 30
    when 2
      text = "this­-is­-soft­-hard­-hyphenated­-text­-" * 30
    end
  end

  options = {
    :width    => bounds.width * 0.3,
    :height   => bounds.width * 0.3,
    :overflow => :ellipses,
    :at       => [0, 0],
    :align    => :left,
    :document => self
  }

  stroke_color("555555")
  3.times do |i|
    options[:at][0] = (bounds.width  - options[:width]) * 0.5 * i
    options[:at][1] = bounds.height * 0.5 + options[:height] + 50
    box = Prawn::Text::Box.new(get_string(i), options)
    box.render
  end

  
  font("#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf")

  stroke_color("555555")
  3.times do |i|
    options[:at][0] = (bounds.width  - options[:width]) * 0.5 * i
    options[:at][1] = bounds.height * 0.5 - 50
    box = Prawn::Text::Box.new(get_string(i), options)
    box.render
  end
end
