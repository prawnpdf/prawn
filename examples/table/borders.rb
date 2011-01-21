# encoding: utf-8
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))
 
Prawn::Document.generate("borders.pdf") do |pdf|
  pdf.text "This example demonstrates alignment of the background and " +
    "borders, including proper corner alignment without overlap."
  pdf.move_down 20

  pdf.cell :content => "all borders", :background_color => 'ff0000'
  pdf.move_down 15

  [:top, :bottom, :left, :right].each do |border|
    y = pdf.cursor
    pdf.cell :content => "no #{border} border", :background_color => 'ff0000',
      :borders => ([:top, :bottom, :left, :right] - [border])
    pdf.cell :content => "#{border} border 0", :background_color => 'ff0000',
      :"border_#{border}_width" => 0, :at => [150, y]
    pdf.cell :content => "#{border} border 2", :background_color => 'ff0000',
      :"border_#{border}_width" => 2, :at => [300, y]
    pdf.move_down 15
  end
end

