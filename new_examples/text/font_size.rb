# encoding: utf-8
# 
# <code>font_size</code> works just like <code>font</code>.
#
# In fact we can even use <code>font</code> with the <code>:size</code> option
# to declare which size we want.
#
# The following snippet speaks by itself:
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Look at the following output from the font method again:"
  move_down 10
  text font.inspect
  
  move_down 20
  text "See that number on the right. That is the same number we will get " +
       " if we call font_size with no params. And that's what we'll do:"
  move_down 10
  text font_size.inspect
  
  move_down 20
  font_size 16
  text "Yeah, something bigger!"
  
  move_down 10
  font_size(25) do
    text "Even bigger!"
  end
  
  move_down 10
  text "Back to 16 again."
  
  move_down 10
  font("Courier", :size => 10) do
    text "Yeah, using Courier 10 courtesy of the font method."
  end
  
  font("Helvetica", :size => 12)  # back to normal
end
