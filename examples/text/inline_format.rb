# encoding: utf-8
#
# This example shows how to use inline formatting
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "inline_format.pdf" do |pdf|
  
  pdf.text("hello <strikethrough><b>world\nhow <i>are</i></b> you?</strikethrough> world, <u>how are you</u> now?",
       :inline_format => true)
  pdf.text("<font size='14'>left: </font>" + "hello <b>world <font name='Times-Roman' size='28'>how</font> <i>are</i></b> you? <font size='14'><b>Goodbye.</b></font> " * 8,
       :inline_format => true)
  pdf.text("right: " + "hello <b>world how <i>are</i></b> you? " * 2,
       :inline_format => true,
       :align => :right)
  pdf.text("center: " + "hello <b>world how <i>are</i></b> you? " * 2,
       :inline_format => true,
       :align => :center)
  pdf.text("\njustify: " + "hello <b>world <i>goodbye</i></b> " * 12 + "the end ",
       :inline_format => true,
       :align => :justify)
  pdf.text("\njustify: " + "hello world goodbye " * 12 + "the end ",
       :inline_format => true,
       :align => :justify)
  pdf.text("\njustify: " + "hello world goodbye " * 12 + "the end ",
       :align => :justify)

  
  pdf.text("<color rgb='00ff00'>link: <font size='24'>please make</font> <color rgb='#0000ff'><u><link href='http://wiki.github.com/sandal/prawn/'>this</link></u></color> clickable</color>",
       :inline_format => true)

  file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
  pdf.font_families["Action Man"] = {
    :normal      => { :file => file, :font => "ActionMan" },
    :italic      => { :file => file, :font => "ActionMan-Italic" },
    :bold        => { :file => file, :font => "ActionMan-Bold" },
    :bold_italic => { :file => file, :font => "ActionMan-BoldItalic" }
  }

  pdf.font("Action Man")
  pdf.text("\nhello <b>world\nhow <i>are</i></b> you?",
           :inline_format => true)
end
