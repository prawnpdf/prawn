# encoding: utf-8
#
# An early example of TTF font embedding.  Mostly kept for nostalgia's sake.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate "simple_text_ttf.pdf" do       
  fill_color "0000ff"
  font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf" 
  draw_text "Hello World", :at => [200,720], :size => 32         

  font "#{Prawn::BASEDIR}/data/fonts/Chalkboard.ttf"

  pad(20) do
    text "This is chalkboard wrapping " * 20
  end
end
