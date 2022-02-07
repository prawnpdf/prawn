# frozen_string_literal: true

# The <code>font_style</code> method works just like the <code>font</code>
# method.
#
# In fact we can even use <code>font</code> with the <code>:style</code> option
# to declare which size we want.
#
# Another way to change the font size is by supplying the <code>:style</code>
# option to the text methods.
#
# Most font families come with some styles other than normal. Most common are
# <code>bold</code>, <code>italic</code> and <code>bold_italic</code>.

require_relative '../example_helper'

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::ManualBuilder::Example.generate(filename) do
  text "The default style is normal"

  move_down 10
  font_style :bold
  text 'This is bold'

  move_down 10
  font_style :italic
  text 'This is italic (not bold, i.e. existing style is overwritten)'

  move_down 10
  font_style :bold_italic
  text 'This is bold italic'

  move_down 10
  font_style :normal
  text 'Back to normal'

  move_down 10
  text 'A single line of italic', style: :italic

  move_down 10
  font_style :bold do
    text 'A single line of bold'
  end

  move_down 10
  font 'Courier', style: :bold_italic
  text 'This is Courier bold italic'

  font 'Courier'
  text 'This is Courier normal (style is reset when changing font)'
end
