# encoding: utf-8
#
# PNG files come in different flavours - 5 of them. This example embeds
# one of each type as proof that they all work.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

images = [
          ["Type 0", "#{Prawn::BASEDIR}/data/images/web-links.png"],
          ["Type 2", "#{Prawn::BASEDIR}/data/images/ruport.png"],
          ["Type 3", "#{Prawn::BASEDIR}/data/images/rails.png"],
          ["Type 4", "#{Prawn::BASEDIR}/data/images/page_white_text.png"],
          ["Type 6", "#{Prawn::BASEDIR}/data/images/dice.png"],
]

Prawn::Document.generate("png_types.pdf", :page_size => "A5") do
  images.each do |header, file|
    start_new_page unless header.include?("0")
    text header
    image file, :at => [50,450]
  end
end