# encoding: utf-8
#
# This example shows the many ways of setting font sizes in Prawn
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "font_size.pdf", :page_size => "A4" do

  # Explicit global changes
  font 'Helvetica'
  self.font_size = 16

  text 'Font at 16 point'

  # Transactional changes rolled back after block exit
  font_size 9 do
    text 'Font at 9 point'
    # single line changes, not persisted.
    text 'Font at manual override 20 point', :size => 20
    text 'Font at 9 point'
  end

  # Transactional changes rolled back after block exit on full fonts.
  font("Times-Roman", :style => :italic, :size => 12) do
    text "Font in times at 12"
    font_size(16) { text "Font in Times at 16" }
  end

  text 'Font at 16 point'

  font "Courier", :size => 40
  text "40 pt!"
end
