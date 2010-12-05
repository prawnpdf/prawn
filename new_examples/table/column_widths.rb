# encoding: utf-8
#
# Prawn will make a bold attempt to identify the best width for the columns.
# If the end result isn't good, we can override it with some styling.
#
# Individual column widths can be set with the <code>:column_widths</code>
# option. Just provide an array with the sequential width values.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Prawn trying to guess the column widths"
  table([ ["", "", "this is so very looooooooooooooooooooooooooooooong"],
          ["", "here we have a line that is long but with small words", ""],
          ["this is not quite as long as the others", "", ""] ])
  move_down 20
  
  text "Manually setting the column widths"
  table([ ["", "", "this is so very looooooooooooooooooooooooooooooong"],
          ["", "here we have a line that is long but with small words", ""],
          ["this is not quite as long as the others", "", ""] ],
          :column_widths => [140, 160, 240])

end
