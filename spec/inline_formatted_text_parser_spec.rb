# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Formatted::Parser#format" do
  it "should handle sup" do
    string = "<sup>superscript</sup>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "superscript",
                           :styles => [:superscript],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should handle sub" do
    string = "<sub>subscript</sub>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "subscript",
                           :styles => [:subscript],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should handle rgb" do
    string = "<color rgb='#ff0000'>red text</color>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "red text",
                           :styles => [],
                           :color => "ff0000",
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "# should be optional in rgb" do
    string = "<color rgb='ff0000'>red text</color>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "red text",
                           :styles => [],
                           :color => "ff0000",
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should handle cmyk" do
    string = "<color c='0' m='100' y='0' k='0'>magenta text</color>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "magenta text",
                           :styles => [],
                           :color => [0, 100, 0, 0],
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should handle fonts" do
    string = "<font name='Courier'>Courier text</font>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "Courier text",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => "Courier",
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should handle size" do
    string = "<font size='14'>14 point text</font>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "14 point text",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => 14,
                           :character_spacing => nil)
  end
  it "should handle character_spacing" do
    string = "<font character_spacing='2.5'>extra character spacing</font>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "extra character spacing",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => 2.5)
  end
  it "should handle links" do
    string = "<link href='http://example.com'>external link</link>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "external link",
                           :styles => [],
                           :color => nil,
                           :link => "http://example.com",
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should handle local links" do
    string = "<link local='/home/example/foo.bar'>local link</link>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "local link",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => "/home/example/foo.bar",
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should handle anchors" do
    string = "<link anchor='ToC'>internal link</link>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "internal link",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => "ToC",
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should handle higher order characters properly" do
    string = "<b>©\n©</b>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[0]).to eq(:text => "©",
                           :styles => [:bold],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[1]).to eq(:text => "\n",
                           :styles => [:bold],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[2]).to eq(:text => "©",
                           :styles => [:bold],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should convert &lt; &gt;, and &amp; to <, >, and &, respectively" do
    string = "hello <b>&lt;, &gt;, and &amp;</b>"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[1]).to eq(:text => "<, >, and &",
                           :styles => [:bold],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should handle double qoutes around tag attributes" do
    string = 'some <font size="14">sized</font> text'
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[1]).to eq(:text => "sized",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => 14,
                           :character_spacing => nil)
  end
  it "should handle single qoutes around tag attributes" do
    string = "some <font size='14'>sized</font> text"
    array = Prawn::Text::Formatted::Parser.format(string)
    expect(array[1]).to eq(:text => "sized",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => 14,
                           :character_spacing => nil)
  end
  it "should construct a formatted text array from a string" do
    string = "hello <b>world\nhow <i>are</i></b> you?"
    array = Prawn::Text::Formatted::Parser.format(string)

    expect(array[0]).to eq(:text => "hello ",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[1]).to eq(:text => "world",
                           :styles => [:bold],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[2]).to eq(:text => "\n",
                           :styles => [:bold],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[3]).to eq(:text => "how ",
                           :styles => [:bold],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[4]).to eq(:text => "are",
                           :styles => [:bold, :italic],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[5]).to eq(:text => " you?",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should accept <strong> as an alternative to <b>" do
    string = "<strong>bold</strong> not bold"
    array = Prawn::Text::Formatted::Parser.format(string)

    expect(array[0]).to eq(:text => "bold",
                           :styles => [:bold],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[1]).to eq(:text => " not bold",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should accept <em> as an alternative to <i>" do
    string = "<em>italic</em> not italic"
    array = Prawn::Text::Formatted::Parser.format(string)

    expect(array[0]).to eq(:text => "italic",
                           :styles => [:italic],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[1]).to eq(:text => " not italic",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end
  it "should accept <a> as an alternative to <link>" do
    string = "<a href='http://example.com'>link</a> not a link"
    array = Prawn::Text::Formatted::Parser.format(string)

    expect(array[0]).to eq(:text => "link",
                           :styles => [],
                           :color => nil,
                           :link => "http://example.com",
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
    expect(array[1]).to eq(:text => " not a link",
                           :styles => [],
                           :color => nil,
                           :link => nil,
                           :anchor => nil,
                           :local => nil,
                           :font => nil,
                           :size => nil,
                           :character_spacing => nil)
  end

  it "should turn <br>, <br/> into newline" do
    array = Prawn::Text::Formatted::Parser.format("hello<br>big<br/>world")
    expect(array.map { |frag| frag[:text] }.join).to eq("hello\nbig\nworld")
  end
end

describe "Text::Formatted::Parser#to_string" do
  it "should handle sup" do
    string = "<sup>superscript</sup>"
    array = [{ :text => "superscript",
               :styles => [:superscript],
               :color => nil,
               :link => nil,
               :anchor => nil,
               :local => nil,
               :font => nil,
               :size => nil,
               :character_spacing => nil }]
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should handle sub" do
    string = "<sub>subscript</sub>"
    array = [{ :text => "subscript",
               :styles => [:subscript],
               :color => nil,
               :link => nil,
               :anchor => nil,
               :local => nil,
               :font => nil,
               :size => nil,
               :character_spacing => nil }]
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should handle rgb" do
    string = "<color rgb='ff0000'>red text</color>"
    array = [{ :text => "red text",
               :styles => [],
               :color => "ff0000",
               :link => nil,
               :anchor => nil,
               :local => nil,
               :font => nil,
               :size => nil,
               :character_spacing => nil }]
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should handle cmyk" do
    string = "<color c='0' m='100' y='0' k='0'>magenta text</color>"
    array = [{ :text => "magenta text",
               :styles => [],
               :color => [0, 100, 0, 0],
               :link => nil,
               :anchor => nil,
               :local => nil,
               :font => nil,
               :size => nil,
               :character_spacing => nil }]
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should handle fonts" do
    string = "<font name='Courier'>Courier text</font>"
    array = [{ :text => "Courier text",
               :styles => [],
               :color => nil,
               :link => nil,
               :anchor => nil,
               :local => nil,
               :font => "Courier",
               :size => nil,
               :character_spacing => nil }]
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should handle size" do
    string = "<font size='14'>14 point text</font>"
    array = [{ :text => "14 point text",
               :styles => [],
               :color => nil,
               :link => nil,
               :anchor => nil,
               :local => nil,
               :font => nil,
               :size => 14,
               :character_spacing => nil }]
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should handle character spacing" do
    string = "<font character_spacing='2.5'>2.5 extra character spacing</font>"
    array = [{ :text => "2.5 extra character spacing",
               :styles => [],
               :color => nil,
               :link => nil,
               :anchor => nil,
               :local => nil,
               :font => nil,
               :size => nil,
               :character_spacing => 2.5 }]
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should handle links" do
    array = [{ :text => "external link",
               :styles => [],
               :color => nil,
               :link => "http://example.com",
               :anchor => nil,
               :local => nil,
               :font => nil,
               :size => nil,
               :character_spacing => nil }]
    string = "<link href='http://example.com'>external link</link>"
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should handle anchors" do
    array = [{ :text => "internal link",
               :styles => [],
               :color => nil,
               :link => nil,
               :anchor => "ToC",
               :font => nil,
               :size => nil,
               :character_spacing => nil }]
    string = "<link anchor='ToC'>internal link</link>"
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should convert <, >, and & to &lt; &gt;, and &amp;, respectively" do
    array = [
      {
        :text => "hello ",
        :styles => [],
        :color => nil,
        :link => nil,
        :font => nil,
        :size => nil,
        :character_spacing => nil
      },
      {
        :text => "<, >, and &",
        :styles => [:bold],
        :color => nil,
        :link => nil,
        :font => nil,
        :size => nil,
        :character_spacing => nil
      }
    ]
    string = "hello <b>&lt;, &gt;, and &amp;</b>"
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
  it "should construct an HTML-esque string from a formatted text array" do
    array = [
      { :text => "hello ",
        :styles => [],
        :color => nil,
        :link => nil,
        :font => nil,
        :size => 14,
        :character_spacing => nil },
      { :text => "world",
        :styles => [:bold],
        :color => nil,
        :link => nil,
        :font => nil,
        :size => nil,
        :character_spacing => nil },
      { :text => "\n",
        :styles => [:bold],
        :color => nil,
        :link => nil,
        :font => nil,
        :size => nil,
        :character_spacing => nil },
      { :text => "how ",
        :styles => [:bold],
        :color => nil,
        :link => nil,
        :font => nil,
        :size => nil,
        :character_spacing => nil },
      { :text => "are",
        :styles => [:bold, :italic],
        :color => nil,
        :link => nil,
        :font => nil,
        :size => nil,
        :character_spacing => nil },
      { :text => " you?",
        :styles => [],
        :color => nil,
        :link => nil,
        :font => nil,
        :size => nil,
        :character_spacing => nil }
    ]
    string = "<font size='14'>hello </font><b>world</b><b>\n</b><b>how </b><b><i>are</i></b> you?"
    expect(Prawn::Text::Formatted::Parser.to_string(array)).to eq(string)
  end
end

describe "Text::Formatted::Parser#array_paragraphs" do
  it "should group fragments separated by newlines" do
    array = [{ :text => "\nhello\nworld" },
             { :text => "\n\n" },
             { :text => "how" },
             { :text => "are" },
             { :text => "you" }]
    target = [[{ :text => "\n" }],
              [{ :text => "hello" }],
              [{ :text => "world" }],
              [{ :text => "\n" }],
              [{ :text => "how" },
               { :text => "are" },
               { :text => "you" }]]
    expect(Prawn::Text::Formatted::Parser.array_paragraphs(array)).to eq(target)
  end

  it "should work properly if ending in an empty paragraph" do
    array = [{ :text => "\nhello\nworld\n" }]
    target = [[{ :text => "\n" }],
              [{ :text => "hello" }],
              [{ :text => "world" }]]
    expect(Prawn::Text::Formatted::Parser.array_paragraphs(array)).to eq(target)
  end
end
