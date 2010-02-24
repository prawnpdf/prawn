# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Formatted::Wrap" do
  it "should only return an empty string if nothing fit or there" +
     "was nothing to wrap" do
    create_pdf
    inline_format = Prawn::Text::Formatted::InlineFormatter.new
    array = [{ :text => "hello\nworld\n\n\nhow are you?" },
             { :text => "\n" },
             { :text => "\n" },
             { :text => "" },
             { :text => "fine, thanks." * 7 },
             { :text => "" },
             { :text => "\n" },
             { :text => "" }]
    inline_format.format_array = array
    line_wrap = Prawn::Text::Formatted::LineWrap.new
    8.times do
      line = line_wrap.wrap_line(:inline_format => inline_format,
                                 :width => 300,
                                 :document => @pdf)
      line.should.not.be.empty
    end
    line = line_wrap.wrap_line(:inline_format => inline_format,
                               :width => 300,
                               :document => @pdf)
    line.should.be.empty
  end
end
