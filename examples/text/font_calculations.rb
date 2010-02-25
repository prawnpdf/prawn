# encoding: utf-8
# 
# This example is a demonstration of how Prawn does its text positioning,
# meant to assist those that need to do advanced positioning calculations.
# Run the example for a clearer picture of how things work
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate('font_calculations.pdf') do
  
  def demonstration
    font_size 12
    move_down 10

    stroke_horizontal_rule

    text "When using flowing text, Prawn will position text\n" +
         "starting font.ascender below the baseline, and leave\n" +
         "the y-cursor at the baseline of the next line of text"

    stroke_horizontal_rule

    move_down 20

    bl = y - bounds.absolute_bottom

    stroke_horizontal_rule
    draw_text "When using text positioned with :at, the baseline is used", :at => [0, bl]

    draw_text "(and the Y-cursor is not moved)", :at => [350, bl]

    colors = { :ascender    => "ff0000", 
               :descender   => "00ff00",
               :line_gap    => "0000ff",
               :font_height => "005500" }


    pad(20) do                    
      text "Calculations Demo", :size => 16
    end

    fill_color colors[:ascender]
    text "ASCENDER"

    fill_color colors[:descender]
    text "DESCENDER"

    fill_color colors[:line_gap]
    text "LINEGAP" 

    fill_color colors[:font_height]
    text "FONT_HEIGHT"

    fill_color "000000"
    font_size 16

    move_down 40

    bl = y - bounds.absolute_bottom
    draw_text "The quick brown fox jumps over the lazy dog.", :at => [0, bl]

    stroke_color colors[:ascender]
    stroke_line [0, bl], [0, bl + font.ascender]
    stroke_line [0, bl + font.ascender], [bounds.width, bl + font.ascender]

    stroke_color colors[:descender]
    stroke_line [0,bl], [0, bl - font.descender]
    stroke_line [0, bl - font.descender], [bounds.width, bl - font.descender]

    stroke_color colors[:line_gap]
    stroke_line [0, bl - font.descender], [0,bl - font.descender - font.line_gap]
    stroke_line [0, bl - font.descender - font.line_gap], 
                [bounds.width,bl - font.descender - font.line_gap]

    stroke_color colors[:font_height]
    stroke_line [bounds.width, bl + font.ascender],
                [bounds.width, bl - font.descender - font.line_gap]
                
    stroke_color "000000"
    fill_color "000000"
  end
  
  text "Using AFM", :size => 20
  demonstration
  
  move_down 75
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
  text "Using TTF", :size => 20
  demonstration
  
end
