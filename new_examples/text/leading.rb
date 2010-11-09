# encoding: utf-8
# 
# Leading is the additional space between lines of text.
#
# The leading can be set using the <code>default_leading</code> where it will
# apply for the rest of the document or inline in the text methods with the
# <code>:leading</code> option.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Hey, what did you do with the space between my lines? " * 10,
       :leading => 0
  
  move_down 20
  default_leading 5
  text "Hey, what did you do with the space between my lines? " * 10
  
  move_down 20
  text "Hey, what did you do with the space between my lines? " * 10,
       :leading => 10
  
  default_leading 0  # back to normal
end
