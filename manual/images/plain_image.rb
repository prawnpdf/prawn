# encoding: utf-8
#
# To embed images onto your PDF file use the <code>image</code> method.
# It accepts the file path of the image to be loaded and some optional
# arguments.
#
# If only the image path is provided the image will be rendered starting on
# the cursor position. No manipulation is done with the image even if it doesn't
# fit entirely on the page like the following snippet.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "The image will go right below this line of text."
  image "#{Prawn::DATADIR}/images/pigs.jpg"
end
