# encoding: utf-8
#
# This will be the introdutory text for the pdf page
# 
# To draw a simple hexagon filled red just do
#
require File.join(File.dirname(__FILE__), '..', 'example_helper.rb')

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  drawing_box(:height => 300) do
    fill_color "ff0000"
    fill_polygon [50, 200], [150, 250], [250, 200],
                 [250, 100], [150, 50], [50, 100]

    # return fill color back to normal
    fill_color "000000"
  end
end
