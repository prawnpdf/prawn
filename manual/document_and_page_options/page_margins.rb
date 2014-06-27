# encoding: utf-8
#
# The default margin for pages is 0.5 inch but you can change that with the
# <code>:margin</code> option or if you'd like to have different margins you
# can use the <code>:left_margin</code>, <code>:right_margin</code>,
# <code>:top_margin</code>, <code>:bottom_margin</code> options.
#
# These options are available both for starting new pages and creating new
# documents.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate("page_margins.pdf",
                         :margin => 100
) do
  text "100 pts margins."
  stroke_bounds

  start_new_page(:left_margin => 300)
  text "300 pts margin on the left."
  stroke_bounds

  start_new_page(:top_margin => 300)
  text "300 pts margin both on the top and on the left. Notice that whenever " +
       "you set an option for a new page it will remain the default for the " +
       "following pages."
  stroke_bounds

  start_new_page(:margin => 50)
  text "50 pts margins. Using the margin option will reset previous specific " +
       "calls to left, right, top and bottom margins."
  stroke_bounds

  start_new_page(:margin => [50, 100, 150, 200])
  text "There is also the shorthand CSS like syntax used here."
  stroke_bounds
end
