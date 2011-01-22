# encoding: utf-8
# 
# Horizontal text alignment can be achieved by supplying the <code>:align</code> option
# to the text methods. Available options are <code>:left</code>,
# <code>:right</code>, and <code>:center</code>, with <code>:left</code> as
# default.
#
# Vertical text alignment can be achieved using the <code>:valign</code> option
# with the text methods. Available options are <code>:top</code>,
# <code>:center</code>, and <code>:bottom</code>, with <code>:top</code> as
# default.
#
# Both forms of alignment will be evaluated in the context of the current
# bounding_box.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "This text should be left aligned"
  text "This text should be centered",      :align => :center
  text "This text should be right aligned", :align => :right
  
  bounding_box([0, 250], :width => 250, :height => 250) do
    text "This text is flowing from the left. "   * 5
    
    move_down 20
    text "This text is flowing from the center. " * 5, :align => :center
    
    move_down 20
    text "This text is flowing from the right. "  * 5, :align => :right
    transparent(0.5) { stroke_bounds }
  end
  
  bounding_box([300, 250], :width => 250, :height => 250) do
    text "This text should be vertically top aligned"
    text "This text should be vertically centered",       :valign => :center    
    text "This text should be vertically bottom aligned", :valign => :bottom
    transparent(0.5) { stroke_bounds }
  end
end
