# encoding: utf-8
#
# Demonstrates extending Text::Box
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "shaped_text_box.pdf" do |pdf|
  module ShapedBox
    def available_width
      height + 25
    end
  end

  Prawn::Text::Box.extensions << ShapedBox
  pdf.stroke_rectangle([10, pdf.bounds.top - 10], 300, 300)
  pdf.text_box("A" * 500,
               :at => [10, pdf.bounds.top - 10],
               :width => 300,
               :height => 300,
               :align => :center)
  
  Prawn::Text::Formatted::Box.extensions << ShapedBox
  pdf.stroke_rectangle([10, pdf.bounds.top - 330], 300, 300)
  pdf.formatted_text_box([:text => "A" * 500,
                          :color => "009900"],
                         :at => [10, pdf.bounds.top - 330],
                         :width => 300,
                         :height => 300,
                         :align => :center)
end

