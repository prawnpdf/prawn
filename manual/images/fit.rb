# encoding: utf-8
#
# <code>:fit</code> option is useful when you want the image to have the
# maximum size within a container preserving the aspect ratio without
# overlapping.
#
# Just provide the container width and height pair.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  size = 300
  
  text "Using the fit option"
  bounding_box([0, cursor], :width => size, :height => size) do
    image "#{Prawn::DATADIR}/images/pigs.jpg", :fit => [size, size]
    stroke_bounds
  end
end
