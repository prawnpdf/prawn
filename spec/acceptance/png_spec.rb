# encoding: utf-8

require_relative "../../lib/prawn"

images = [
  ["Type 0", "#{Prawn::BASEDIR}/data/images/web-links.png"],
  ["Type 2", "#{Prawn::BASEDIR}/data/images/ruport.png"],
  ["Type 3", "#{Prawn::BASEDIR}/data/images/indexed_color.png"],
  ["Type 4", "#{Prawn::BASEDIR}/data/images/page_white_text.png"],
  ["Type 6", "#{Prawn::BASEDIR}/data/images/dice.png"]
]

Prawn::Document.generate("png_types.pdf", :page_size => "A5") do
  images.each do |header, file|
    start_new_page unless header.include?("0")

    fill_color "FF0000"

    fill_rectangle bounds.top_left, bounds.width, bounds.height
    text header

    image file, :at => [50, 450]
  end
end
