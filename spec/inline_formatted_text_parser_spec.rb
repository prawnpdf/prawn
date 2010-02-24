# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::InlineFormattedTextParser#to_array" do
  it "should handle higher order characters properly" do
    string = "<b>©\n©</b>"
    array = Prawn::Text::InlineFormattedTextParser.to_array(string)
    array[0].should == { :text => "©",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
    array[1].should == { :text => "\n",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
    array[2].should == { :text => "©",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should convert &lt; &gt;, and &amp; to <, >, and &, respectively" do
    string = "hello <b>&lt;, &gt;, and &amp;</b>"
    array = Prawn::Text::InlineFormattedTextParser.to_array(string)
    array[1].should == { :text => "<, >, and &",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should handle double qoutes around tag attributes" do
    string = 'some <font size="14">sized</font> text'
    array = Prawn::Text::InlineFormattedTextParser.to_array(string)
    array[1].should == { :text => "sized",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => 14 }
  end
  it "should handle single qoutes around tag attributes" do
    string = "some <font size='14'>sized</font> text"
    array = Prawn::Text::InlineFormattedTextParser.to_array(string)
    array[1].should == { :text => "sized",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => 14 }
  end
  it "should construct a formatted text array from a string" do
    string = "hello <b>world\nhow <i>are</i></b> you?"
    array = Prawn::Text::InlineFormattedTextParser.to_array(string)

    array[0].should == { :text => "hello ",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
    array[1].should == { :text => "world",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
    array[2].should == { :text => "\n",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
    array[3].should == { :text => "how ",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
    array[4].should == { :text => "are",
                         :style => [:bold, :italic],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
    array[5].should == { :text => " you?",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :font => nil,
                         :size => nil }
  end
end


describe "Text::InlineFormattedTextParser#to_string" do
  it "should convert <, >, and & to &lt; &gt;, and &amp;, respectively" do
    array = [{ :text => "hello ",
               :style => [],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
            { :text => "<, >, and &",
               :style => [:bold],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil }]
    string = "hello <b>&lt;, &gt;, and &amp;</b>"
    Prawn::Text::InlineFormattedTextParser.to_string(array).should == string
  end
  it "should construct an HTML-esque string from a formatted" +
    " text array" do
    array = [
             { :text => "hello ",
               :style => [],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => 14 },
             { :text => "world",
               :style => [:bold],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
             { :text => "\n",
               :style => [:bold],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
             { :text => "how ",
               :style => [:bold],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
             { :text => "are",
               :style => [:bold, :italic],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
             { :text => " you?",
               :style => [],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil }
             ]
    string = "<font size='14'>hello </font><b>world</b><b>\n</b><b>how </b><b><i>are</i></b> you?"
    Prawn::Text::InlineFormattedTextParser.to_string(array).should == string
  end
end
