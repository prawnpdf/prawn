# encoding: utf-8
#
# The image size can be set with the <code>:width</code> and
# <code>:height</code> options.
#
# If only one of those is provided, the image will be scaled proportionally.
# When both are provided, the image will be stretched to fit the dimensions
# without maintaining the aspect ratio.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Scale by setting only the width"
  image "#{Prawn::DATADIR}/images/pigs.jpg", :width => 150
  move_down 10
  
  text "Scale by setting only the height"
  image "#{Prawn::DATADIR}/images/pigs.jpg", :height => 100
  move_down 10
  
  text "Stretch to fit the width and height provided"
  image "#{Prawn::DATADIR}/images/pigs.jpg", :width => 500, :height => 100
end
