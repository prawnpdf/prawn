# encoding: utf-8
#
# There are generally two colors (or pens) that are active at any
# given time: the <i>stroke-color</i> which is used for drawning
# lines, and the <i>fill-color</i> which is used to paint in areas as
# well as drawing text.
#
# There are several ways that these colors may be set: whether
# directly with the <code>stroke_color</code> and
# <code>fill_color</code> methods; passed as options to other
# rendering functions; or even inside of text with HTML-like
# inline markup.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Text using the :color option", :color => "teal"

  move_down 20.mm

  text "Text " +
       "<color css='red'>using</color> " +
       "<color css='#006099'>inline</color> " +
       "<color rgb='bb8822'>formatting</color>",
       :inline_format => true

  move_down 20.mm

  stroke_color "hotpink"
  fill_color "skyblue"

  self.line_width 4.mm
  fill_and_stroke_rectangle [100, 240], 250, 70
end
