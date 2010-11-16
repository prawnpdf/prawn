# encoding: utf-8
#
# Example of character spacing
#
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate "rendering_mode.pdf" do |pdf|
  pdf.fill_color "00ff00"
  pdf.stroke_color "0000ff"

  # inline rendering mode
  pdf.text("Inline mode", :mode => :stroke, :size => 40)

  # block rendering mode
  pdf.text_rendering_mode(:stroke) do
    pdf.text("Block", :size => 30)
    pdf.text("Mode", :size => 30)
  end
end
