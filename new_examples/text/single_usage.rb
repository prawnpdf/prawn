# encoding: utf-8
#
# The Pdf format has some built-in font support. If you want to use other fonts
# in Prawn you need to embed the font file.
#
# Doing this for a single font is extremely simple. Remember the Styling font
# example? Another use of the <code>font</code> method is to provide a font file
# path and the font will be embedded in the document and set as the current
# font.
#
# This is quite cumbersome as every time we need to use the font we
# would need to provide its file path. If using the font is a one shot thing
# than this way is fine, if the font will be used many times the next example
# shows a less cumbersome way of doing it.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  # Using a TTF font file
  font "#{Prawn::BASEDIR}/data/fonts/Chalkboard.ttf" do
    text "Written with the Chalkboard TTF font."
  end
  move_down 20
  
  text "Written with the default font."
  move_down 20
  
  # Using an DFONT font file
  font "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont" do
    text "Written with the Action Man DFONT font"
  end
  move_down 20

  text "Written with the default font once more."
end
