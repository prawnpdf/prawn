# encoding: utf-8
#
# This example shows how to use inline formatting
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "inline_format.pdf" do |pdf|
  pdf.text("hello <b>world\nhow <i>are</i></b> you?",
       :inline_format => true)
  pdf.text("hello <b>world how <i>are</i></b> you? " * 20,
       :inline_format => true)
  pdf.text("hello <b>world how <i>are</i></b> you? " * 2,
       :inline_format => true,
       :align => :right)
  pdf.text("hello <b>world <i>goodbye</i></b> " * 3,
       :inline_format => true,
       :align => :right)

  
  file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
  pdf.font_families["Action Man"] = {
    :normal      => { :file => file, :font => "ActionMan" },
    :italic      => { :file => file, :font => "ActionMan-Italic" },
    :bold        => { :file => file, :font => "ActionMan-Bold" },
    :bold_italic => { :file => file, :font => "ActionMan-BoldItalic" }
  }

  pdf.font("Action Man")
  pdf.text("hello <b>world\nhow <i>are</i></b> you?",
           :inline_format => true)
end
