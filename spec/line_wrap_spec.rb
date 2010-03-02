# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Wrap" do
  it "should strip preceding and trailing spaces" do
    create_pdf
    line_wrap = Prawn::Text::LineWrap.new
    string = line_wrap.wrap_line("    hello world    ",
                                 :width => 300,
                                 :document => @pdf)
    string.should == "hello world"
  end

  it "should raise CannotFit if a too-small width is given" do
    create_pdf
    line_wrap = Prawn::Text::LineWrap.new
    lambda do
      line_wrap.wrap_line("    hello world    ",
                          :width => 1,
                          :document => @pdf)
    end.should.raise(Prawn::Errors::CannotFit)
  end
end

describe "Text::Wrap#consumed_char_count" do
  it "should return the total number of characters incorporated into" +
     " or deleted from the last line" do
    create_pdf
    line_wrap = Prawn::Text::LineWrap.new
    string = line_wrap.wrap_line("    hello world    ",
                                 :width => 300,
                                 :document => @pdf)
    line_wrap.consumed_char_count.should == 19
  end
end

describe "Text::Wrap#width" do
  it "should return the width of the last wrapped line" do
    create_pdf
    line_wrap = Prawn::Text::LineWrap.new
    line_wrap.wrap_line("hello world" * 10,
                        :width => 300,
                        :document => @pdf)
    line_wrap.width.should.be > 0
    line_wrap.width.should.be <= 300
  end
end

describe "Text::Wrap#space_count" do
  it "should return the number of spaces in the last wrapped line" do
    create_pdf
    line_wrap = Prawn::Text::LineWrap.new
    line_wrap.wrap_line("hello world, goobye",
                        :width => 300,
                        :document => @pdf)
    line_wrap.space_count.should == 2
  end
  it "should exclude trailing spaces from the count" do
    create_pdf
    line_wrap = Prawn::Text::LineWrap.new
    line_wrap.wrap_line("hello world, goobye  ",
                        :width => 300,
                        :document => @pdf)
    line_wrap.space_count.should == 2
  end
end

describe "Text::Formatted::Wrap" do
  it "should strip preceding and trailing spaces" do
    create_pdf
    arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => " hello world, " },
             { :text => "goodbye  ", :style => [:bold] }]
    arranger.format_array = array
    line_wrap = Prawn::Text::Formatted::LineWrap.new
    string = line_wrap.wrap_line(:arranger => arranger,
                                 :width => 300,
                                 :document => @pdf)
    string.should == "hello world, goodbye"
  end
  it "should strip trailing spaces when we try but fail to push any of a" +
     " fragment onto the end of a line that currently ends with a space" do
    create_pdf
    arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa " },
             { :text => "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb ", :style => [:bold] }]
    arranger.format_array = array
    line_wrap = Prawn::Text::Formatted::LineWrap.new
    string = line_wrap.wrap_line(:arranger => arranger,
                                 :width => 300,
                                 :document => @pdf)
    string.should == "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  end
  it "should strip trailing spaces when a white-space-only fragment was" +
     " successfully pushed onto the end of a line but no other non-white" +
     " space fragment fits after it" do
    create_pdf
    arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa " },
             { :text => "  ", :style => [:bold] },
             { :text => " bbbbbbbbbbbbbbbbbbbbbbbbbbbb" }]
    arranger.format_array = array
    line_wrap = Prawn::Text::Formatted::LineWrap.new
    string = line_wrap.wrap_line(:arranger => arranger,
                                 :width => 300,
                                 :document => @pdf)
    string.should == "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  end
  it "should raise CannotFit if a too-small width is given" do
    create_pdf
    arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => " hello world, " },
             { :text => "goodbye  ", :style => [:bold] }]
    arranger.format_array = array
    line_wrap = Prawn::Text::Formatted::LineWrap.new
    lambda do
      line_wrap.wrap_line(:arranger => arranger,
                                 :width => 1,
                                 :document => @pdf)
    end.should.raise(Prawn::Errors::CannotFit)
  end
end

describe "Text::Formatted::Wrap#space_count" do
  it "should return the number of spaces in the last wrapped line" do
    create_pdf
    arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello world, " },
             { :text => "goodbye", :style => [:bold] }]
    arranger.format_array = array
    line_wrap = Prawn::Text::Formatted::LineWrap.new
    line_wrap.wrap_line(:arranger => arranger,
                        :width => 300,
                        :document => @pdf)
    line_wrap.space_count.should == 2
  end
  it "should exclude preceding and trailing spaces from the count" do
    create_pdf
    arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => " hello world, " },
             { :text => "goodbye  ", :style => [:bold] }]
    arranger.format_array = array
    line_wrap = Prawn::Text::Formatted::LineWrap.new
    line_wrap.wrap_line(:arranger => arranger,
                        :width => 300,
                        :document => @pdf)
    line_wrap.space_count.should == 2
  end
end

describe "Text::Formatted::Wrap" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello\nworld\n\n\nhow are you?" },
             { :text => "\n" },
             { :text => "\n" },
             { :text => "" },
             { :text => "fine, thanks. " * 4 },
             { :text => "" },
             { :text => "\n" },
             { :text => "" }]
    @arranger.format_array = array
    @line_wrap = Prawn::Text::Formatted::LineWrap.new
  end
  it "should only return an empty string if nothing fit or there" +
     "was nothing to wrap" do
    8.times do
      line = @line_wrap.wrap_line(:arranger => @arranger,
                                 :width => 200,
                                 :document => @pdf)
      line.should.not.be.empty
    end
    line = @line_wrap.wrap_line(:arranger => @arranger,
                               :width => 200,
                               :document => @pdf)
    line.should.be.empty
  end
end
