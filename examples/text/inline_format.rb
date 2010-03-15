# encoding: utf-8
#
# This example shows how to use inline formatting
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "inline_format.pdf" do
  
  text("hello <strikethrough><b>world\nhow <i>are</i></b> you?</strikethrough> world, <u>how are you</u> now?",
       :inline_format => true)
  text("<font size='14'>left: </font>" + "hello <b>world <font name='Times-Roman' size='28'>how</font> <i>are</i></b> you? <font size='14'><b>Goodbye.</b></font> " * 8,
       :inline_format => true)
  text("right: " + "hello <b>world how <i>are</i></b> you? " * 2,
       :inline_format => true,
       :align => :right)
  text("center: " + "hello <b>world how <i>are</i></b> you? " * 2,
       :inline_format => true,
       :align => :center)
  text("\njustify: " + "hello <b>world <i>goodbye</i></b> " * 12 + "the end ",
       :inline_format => true,
       :align => :justify)
  text("\njustify: " + "hello world goodbye " * 12 + "the end ",
       :inline_format => true,
       :align => :justify)
  text("\njustify: " + "hello world goodbye " * 12 + "the end ",
       :align => :justify)

  
  text("<color rgb='00ff00'>link: <font size='24'>please make</font> <color rgb='#0000ff'><u><link href='http://wiki.github.com/sandal/prawn/'>this</link></u></color> clickable.</color> Here we have A<color rgb='#0000ff'><sup><link href='http://wiki.github.com/sandal/prawn/'>superscript</link></sup></color> link and A<color rgb='#0000ff'><sub><link href='http://wiki.github.com/sandal/prawn/'> subscript</link></sub></color> link.",
       :inline_format => true)

  text("<color c='100' m='0' y='0' k='0'><font size='24'>CMYK</font></color>",
       :inline_format => true)

  file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
  font_families["Action Man"] = {
    :normal      => { :file => file, :font => "ActionMan" },
    :italic      => { :file => file, :font => "ActionMan-Italic" },
    :bold        => { :file => file, :font => "ActionMan-Bold" },
    :bold_italic => { :file => file, :font => "ActionMan-BoldItalic" }
  }

  font("Action Man")
  text("\nhello <b>world\nhow <i>are</i></b> you?",
           :inline_format => true)

  def draw_circles_at_corners(fragment, radius, connect_corners)
    box = fragment.bounding_box
    if connect_corners
      polygon([box[0], box[1]],
              [box[0], box[3]],
              [box[2], box[3]],
              [box[2], box[1]])
    end
    stroke_circle_at([box[0], box[1]], :radius => radius)
    stroke_circle_at([box[0], box[3]], :radius => radius)
    stroke_circle_at([box[2], box[1]], :radius => radius)
    stroke_circle_at([box[2], box[3]], :radius => radius)
  end

  font("Helvetica")
  formatted_text([
                      { :text => "\n" },
                      { :text => "hello   " },
                      { :text => "world",
                        :size => 24,
                        :callback => { :object => self,
                                       :method => :draw_circles_at_corners,
                                       :arguments => [2.5, true] }},
                      { :text => "   hello" }
                     ], :indent_paragraphs => 40)
end
