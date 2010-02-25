# encoding: utf-8
#
# Generates a ruler and also demonstrates prawn/measurement_extensions.
# It's better to run this example and examine its output than to worry about
# its particular implementation, though some might find that interesting as
# well.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

require "prawn/measurement_extensions"

# this makes the following units available (Millimeters, Centimeters, Decimeters, Meters, Inches, Foot, Yards, Points)
# Methodname is the common abbravation for the unit (mm, cm, dm, m, in, ft, yd, pt)
# Usage: '10.mm'. 
# This converts 10mm to PDF points, which Prawn uses internally.

pdf = Prawn::Document.new(
:page_size => "A4", 
:left_margin => 10.mm,    # different
:right_margin => 1.cm,    # units
:top_margin => 0.1.dm,    # work
:bottom_margin => 0.01.m) # well

pdf.font_size = 6
pdf.line_width = 0.05

units_long = %w[Millimeters Centimeters Decimeters Inches Foot Points]
units = %w[mm cm dm in ft pt]
offset_multiplier = 2.cm
temp = "Units\n"

units.each_with_index do |unit, unit_index| #iterate through all units that make sense to display on a sheet of paper
  one_unit_in_pt = eval "1.#{unit}" # calc the width of one unit
  temp << "1#{unit} => #{one_unit_in_pt}pt\n" #puts converted unit in points
  
  offset = offset_multiplier * unit_index
  pdf.draw_text units[unit_index], :at => [offset + 0.5.mm, pdf.bounds.top - 2.mm]
  
  pdf.stroke_line(offset, pdf.bounds.top, offset, pdf.bounds.bottom)
  
  0.upto(((pdf.bounds.height - 5.mm) / one_unit_in_pt).to_i) do |i| # checks, how many strokes can be drawn
    pdf.stroke_line(offset, i * one_unit_in_pt, (i % 5 == 0 ? 6.mm : 3.mm) + offset, i * one_unit_in_pt) # every fifth stroke is twice as large like on a real ruler
    pdf.draw_text "#{i}#{unit}", :at => [7.mm + offset, i * one_unit_in_pt] unless unit == "mm" && i % 5 != 0 || unit == "pt" && i % 10 != 0 # avoid text too close to each other
  end    
end

pdf.text_box temp,
  :width    => 5.cm, :height => pdf.font.height * units_long.length,
  :at       => [offset_multiplier * units_long.length, pdf.bounds.top]

pdf.render_file "measurement_units.pdf"
