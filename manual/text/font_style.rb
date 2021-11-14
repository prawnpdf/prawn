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
  fonts = %w[Courier Helvetica Times-Roman]
  styles = %i[bold bold_italic italic normal]

  fonts.each do |example_font|
    move_down 20

    styles.each do |style|
      font example_font, style: style
      text "I'm writing in #{example_font} (#{style})"

      font_style style
      text "This is also #{style}"

      text "And this is also #{style}", style: style
    end
  end
end
