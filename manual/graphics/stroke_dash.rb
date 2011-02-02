# encoding: utf-8
#
# This sets the dashed pattern for lines and curves.
#
# The (dash) length defines how long each dash will be.
#
# The <code>:space</code> option defines the length of the space between the
# dashes.
#
# The <code>:phase</code> option defines the start point of the sequence of
# dashes and spaces. 
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  base_y = 210
  
  24.times do |i|
    length = (i / 4) + 1
    space = length            # space between dashes same length as dash
    phase = 0                 # start with dash
    
    case i % 4
    when 0
      base_y -= 5
    when 1
      phase = length          # start with space between dashes
    when 2
      space = length * 0.5    # space between dashes half as long as dash
    when 3
      space = length * 0.5    # space between dashes half as long as dash
      phase = length          # start with space between dashes
    end
    base_y -= 5
    
    dash(length, :space => space, :phase => phase)
    stroke_horizontal_line 50, 500, :at => base_y - (2 * i)
  end
  
  undash                      # revert stroke back to normal
end
