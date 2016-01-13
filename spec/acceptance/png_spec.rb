# encoding: utf-8

require_relative "../../spec/spec_helper"

describe "When making a pdf file with png images" do
  image_dir = "#{Prawn::BASEDIR}/data/images"
  images = [
    ["Type 0", "#{image_dir}/web-links.png"],
    ["Type 0 with transparency", "#{image_dir}/ruport_type0.png"],
    ["Type 2", "#{image_dir}/ruport.png"],
    ["Type 2 with transparency", "#{image_dir}/arrow2.png"],
    ["Type 3", "#{image_dir}/indexed_color.png"],
    ["Type 3 with transparency", "#{image_dir}/indexed_transparency.png"],
    ["Type 4", "#{image_dir}/page_white_text.png"],
    ["Type 6", "#{image_dir}/dice.png"],
    ["Type 6 in 16bit", "#{image_dir}/16bit.png"]
  ]

  images.each do |header, file|
    describe "and the image is #{header}" do
      it "does not error" do
        expect do
          Prawn::Document.generate("#{header}.pdf", :page_size => "A5") do
            start_new_page unless header.include?("0")

            fill_color "00FF00"

            fill_rectangle bounds.top_left, bounds.width, bounds.height
            text header

            image file, :at => [50, 450]
          end
        end.to_not raise_error
      end
    end
  end
end
