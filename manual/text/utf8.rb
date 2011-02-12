# encoding: utf-8
# 
# Multilingualization isn't much of a problem on Prawn as its default encoding
# is UTF-8. The only thing you need to worry about is if the font support the
# glyphs of your language.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Take this example, a simple Euro sign:"
  text "€", :size => 32
  move_down 20
  
  text "Seems ok. Now let's try something more complex:"
  text "ὕαλον ϕαγεῖν δύναμαι· τοῦτο οὔ με βλάπτει."
  move_down 20
  
  text "Looks like the current font (#{font.inspect}) doesn't support those."
  text "Let's try them with another font."
  move_down 20
  
  font("#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf") do
    text "ὕαλον ϕαγεῖν δύναμαι· τοῦτο οὔ με βλάπτει."
    text "There you go."
  end
end
