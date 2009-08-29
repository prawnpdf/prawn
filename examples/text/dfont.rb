# encoding: utf-8

require "#{File.dirname(__FILE__)}/../example_helper.rb"

DFONT_FILE = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
puts "There are #{Prawn::Font::DFont.font_count(DFONT_FILE)} fonts in #{DFONT_FILE}:"
Prawn::Font::DFont.named_fonts(DFONT_FILE).each do |name|
  puts "* #{name}"
end

puts
puts "generating sample document in 'dfont.pdf'..."

Prawn::Document.generate "dfont.pdf" do       
  fill_color "0000ff"

  font DFONT_FILE, :font => "ActionMan-Bold", :size => 24
  text "Introducing Action Man!"

  move_text_position 24

  font_families["Action Man"] = {
    :normal      => { :file => DFONT_FILE, :font => "ActionMan" },
    :bold        => { :file => DFONT_FILE, :font => "ActionMan-Bold" },
    :italic      => { :file => DFONT_FILE, :font => "ActionMan-Italic" },
    :bold_italic => { :file => DFONT_FILE, :font => "ActionMan-BoldItalic" }
  }

  font "Action Man", :size => 16
  text "Action Man is feeling normal here."

  move_text_position 16

  font "Action Man", :style => :bold, :size => 16
  text "Action Man is feeling bold here!"

  move_text_position 16

  font "Action Man", :style => :italic, :size => 16
  text "Here, we see Action Man feeling italicized. Slick!"

  move_text_position 16

  font "Action Man", :style => :bold_italic, :size => 16
  text "Lastly, we observe Mr. Action Man being bold AND italicized. Excellent!"
end

puts "done"
