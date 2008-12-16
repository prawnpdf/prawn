# encoding: utf-8
#
# A text box is positioned by a top-left corner, width, and height and is
# essentially an invisible rectangle that the text wil lflow within.  If the
# text exceeds the boundaries, it is either truncated, replaced with some
# ellipses, or set to expand beyond the bottom boundary.
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'prawn'

Prawn::Document.generate("text_box.pdf") do

  text_box "Oh hai text box. " * 200, 
    :width    => 300, :height => font.height * 5,
    :overflow => :ellipses, 
    :at       => [100,bounds.top]

  text_box "Oh hai text box. " * 200,
    :width    => 250, :height => font.height * 10,
    :overflow => :truncate,
    :at       => [50, 300]

  move_down 20

  text_box "Oh hai text box. " * 100, :overflow => :expand
end