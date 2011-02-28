# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Core::Text::Formatted::Wrap#line_wrap" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    @line_wrap = Prawn::Core::Text::Formatted::LineWrap.new
    @one_word_width = 50
  end
  it "should strip leading spaces" do
    array = [{ :text => " hello world, " },
             { :text => "goodbye  ", :style => [:bold] }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                 :width => 300,
                                 :document => @pdf)
    string.should == "hello world, goodbye  "
  end
  it "should include trailing spaces when a white-space-only fragment was" +
     " successfully pushed onto the end of a line but no other non-white" +
     " space fragment fits after it" do
    array = [{ :text => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa " },
             { :text => "  ", :style => [:bold] },
             { :text => " bbbbbbbbbbbbbbbbbbbbbbbbbbbb" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                 :width => 300,
                                 :document => @pdf)
    string.should == "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa    "
  end
  it "should raise CannotFit if a too-small width is given" do
    array = [{ :text => " hello world, " },
             { :text => "goodbye  ", :style => [:bold] }]
    @arranger.format_array = array
    lambda do
      @line_wrap.wrap_line(:arranger => @arranger,
                           :width => 1,
                           :document => @pdf)
    end.should.raise(Prawn::Errors::CannotFit)
  end

  it "should break on space" do
    array = [{ :text => "hello world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    string.should == "hello "
  end

  it "should break on tab" do
    array = [{ :text => "hello\tworld" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    string.should == "hello\t"
  end

  it "should break on hyphens" do
    array = [{ :text => "hello-world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    string.should == "hello-"
  end
end

describe "Core::Text::Formatted::Wrap#space_count" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    @line_wrap = Prawn::Core::Text::Formatted::LineWrap.new
  end
  it "should return the number of spaces in the last wrapped line" do
    array = [{ :text => "hello world, " },
             { :text => "goodbye", :style => [:bold] }]
    @arranger.format_array = array
    @line_wrap.wrap_line(:arranger => @arranger,
                        :width => 300,
                        :document => @pdf)
    @line_wrap.space_count.should == 2
  end
  it "should exclude preceding and trailing spaces from the count" do
    array = [{ :text => " hello world, " },
             { :text => "goodbye  ", :style => [:bold] }]
    @arranger.format_array = array
    @line_wrap.wrap_line(:arranger => @arranger,
                        :width => 300,
                        :document => @pdf)
    @line_wrap.space_count.should == 2
  end
end

describe "Core::Text::Formatted::Wrap" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello\nworld\n\n\nhow are you?" },
             { :text => "\n" },
             { :text => "\n" },
             { :text => "" },
             { :text => "fine, thanks. " * 4 },
             { :text => "" },
             { :text => "\n" },
             { :text => "" }]
    @arranger.format_array = array
    @line_wrap = Prawn::Core::Text::Formatted::LineWrap.new
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
