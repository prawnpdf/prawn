# encoding: utf-8
#
# To scale an image use the <code>:scale</code> option.
#
# It scales the image proportionally given the provided
# value.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Normal size"
  image "#{Prawn::DATADIR}/images/stef.jpg"
  move_down 10
  
  text "Scaled to 50%"
  image "#{Prawn::DATADIR}/images/stef.jpg", :scale => 0.5
  move_down 10
  
  text "Scaled to 200%"
  image "#{Prawn::DATADIR}/images/stef.jpg", :scale => 2
end
