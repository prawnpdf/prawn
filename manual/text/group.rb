# encoding: utf-8
#
# Sometimes free flowing text might look ugly, specially when a paragraph is
# split between two pages. Using a positioned text box just to overcome this
# nuisance is not the right choice.
#
# You probably want to use the <code>group</code> method instead. It will try
# to render the block within the current page. If the content would fall to a
# new page it just renders everything on the following page. If the block cannot
# be executed on a single blank page a CannotGroup exception will be raised.
#
# So if you can split your text blocks in paragraphs you can have every
# paragraph contained on a single page.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  move_cursor_to 80
  text "Let's move to the end of the page so that you can see group in action."
  
  group do
    text "This block of text was too big to be rendered on the bottom of the " +
         " previous page. So it was rendered entirely on this new page. " +
         " _ " * 200
  end
end
