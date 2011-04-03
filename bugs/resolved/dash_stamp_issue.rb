# encoding: utf-8
#
#
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'prawn'


##
# When resolved the second page circle should not be dashed
pdf = Prawn::Document.generate("stamp_dash_issues.pdf", :margin => [40, 45, 50, 45]) do
  text "The stamped circle might be dashed"
  create_stamp("stamp_circle") do
    dash(5)
    stroke_circle [0, 0], 10
  end
  stamp("stamp_circle")
  text "but the nonstamped circle should not"
  stroke_circle [10, 10], 10
end