# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Core::Text::Formatted::Arranger#format_array" do
  it "should populate unconsumed array" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you?" }]
    arranger.format_array = array
    arranger.unconsumed[0].should == { :text => "hello " }
    arranger.unconsumed[1].should == { :text => "world how ",
                                              :styles => [:bold] }
    arranger.unconsumed[2].should == { :text => "are",
                                              :styles => [:bold, :italic] }
    arranger.unconsumed[3].should == { :text => " you?" }
  end
  it "should split newlines into their own elements" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "\nhello\nworld" }]
    arranger.format_array = array
    arranger.unconsumed[0].should == { :text => "\n" }
    arranger.unconsumed[1].should == { :text => "hello" }
    arranger.unconsumed[2].should == { :text => "\n" }
    arranger.unconsumed[3].should == { :text => "world" }
  end
end
describe "Core::Text::Formatted::Arranger#preview_next_string" do
  it "should not populate the consumed array" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello" }]
    arranger.format_array = array
    arranger.preview_next_string
    arranger.consumed.should == []
  end
  it "should not consumed array" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello" }]
    arranger.format_array = array
    arranger.preview_next_string.should == "hello"
  end
end
describe "Core::Text::Formatted::Arranger#next_string" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you?" }]
    @arranger.format_array = array
  end
  it "should raise an error if called after a line was finalized and" +
     " before a new line was initialized" do
    @arranger.finalize_line
    lambda do
      @arranger.next_string
    end.should.raise(RuntimeError)
  end
  it "should populate consumed array" do
    while string = @arranger.next_string
    end
    @arranger.consumed[0].should == { :text => "hello " }
    @arranger.consumed[1].should == { :text => "world how ",
                                              :styles => [:bold] }
    @arranger.consumed[2].should == { :text => "are",
                                              :styles => [:bold, :italic] }
    @arranger.consumed[3].should == { :text => " you?" }
  end
  it "should populate current_format_state array" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you?" }]
    arranger.format_array = array
    counter = 0
    while string = arranger.next_string
      case counter
      when 0
        arranger.current_format_state.should == { }
      when 1
        arranger.current_format_state.should == { :styles => [:bold] }
      when 2
        arranger.current_format_state.should == { :styles => [:bold, :italic] }
      when 3
        arranger.current_format_state.should == { }
      end
      counter += 1
    end
  end
end

describe "Core::Text::Formatted::Arranger#retrieve_fragment" do
  it "should raise an error if called before finalize_line was called" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you?" }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    lambda do
      arranger.retrieve_fragment
    end.should.raise(RuntimeError)
  end
  it "should return the consumed fragments in order of consumption" +
     " and update" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you?" }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.finalize_line
    arranger.retrieve_fragment.text.should == "hello "
    arranger.retrieve_fragment.text.should == "world how "
    arranger.retrieve_fragment.text.should == "are"
    arranger.retrieve_fragment.text.should == " you?"
  end
  it "should never return a fragment whose text is an empty string" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello\nworld\n\n\nhow are you?" },
             { :text => "\n" },
             { :text => "\n" },
             { :text => "\n" },
             { :text => "" },
             { :text => "fine, thanks." },
             { :text => "" },
             { :text => "\n" },
             { :text => "" }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.finalize_line
    while fragment = arranger.retrieve_fragment
      fragment.text.should.not.be.empty
    end
  end
  it "should not alter the current font style" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you?" }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.finalize_line
    arranger.retrieve_fragment
    arranger.current_format_state[:styles].should.be.nil
  end
end

describe "Core::Text::Formatted::Arranger#update_last_string" do
  it "should update the last retrieved string with what actually fit on" +
     "the line and the list of unconsumed with what did not" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you now?", :styles => [:bold, :italic] }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.update_last_string(" you", " now?", nil)
    arranger.consumed[3].should == { :text => " you",
                                     :styles => [:bold, :italic] }
    arranger.unconsumed.should == [{ :text => " now?",
                                     :styles => [:bold, :italic] }]
  end
  it "should set the format state to the previously processed fragment" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you now?" }]
    arranger.format_array = array
    3.times { arranger.next_string }
    arranger.current_format_state.should == { :styles => [:bold, :italic] }
    arranger.update_last_string("", "are", "-")
    arranger.current_format_state.should == { :styles => [:bold] }
  end

  context "when the entire string was used" do
    it "should not push empty string onto unconsumed" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you now?" }]
    arranger.format_array = array
      while string = arranger.next_string
      end
      arranger.update_last_string(" you now?", "", nil)
      arranger.unconsumed.should == []
    end
  end
end
describe "Core::Text::Formatted::Arranger#space_count" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you?" }]
    @arranger.format_array = array
    while string = @arranger.next_string
    end
  end
  it "should raise an error if called before finalize_line was called" do
    lambda do
      @arranger.space_count
    end.should.raise(RuntimeError)
  end
  it "should return the total number of spaces in all fragments" do
    @arranger.finalize_line
    @arranger.space_count.should == 4
  end
end
describe "Core::Text::Formatted::Arranger#finalize_line" do
  it "should make it so that all trailing white space fragments " +
     "exclude trailing white space" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "   ", :styles => [:bold, :italic] }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.finalize_line
    arranger.fragments.length.should == 3

    fragment = arranger.retrieve_fragment
    fragment.text.should == "hello "

    fragment = arranger.retrieve_fragment
    fragment.text.should == "world how"

    fragment = arranger.retrieve_fragment
    fragment.text.should == ""
  end
end

describe "Core::Text::Formatted::Arranger#line_width" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world", :styles => [:bold] }]
    @arranger.format_array = array
    while string = @arranger.next_string
    end
  end
  it "should raise an error if called before finalize_line was called" do
    lambda do
      @arranger.line_width
    end.should.raise(RuntimeError)
  end
  it "should return the width of the complete line" do
    @arranger.finalize_line
    @arranger.line_width.should.be > 0
  end
end

describe "Core::Text::Formatted::Arranger#line_width with character_spacing > 0" do
  it "should return a width greater than a line without a character_spacing" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)

    array = [{ :text => "hello " },
             { :text => "world", :styles => [:bold] }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.finalize_line

    base_line_width = arranger.line_width


    array = [{ :text => "hello " },
             { :text => "world", :styles => [:bold],
               :character_spacing => 7}]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.finalize_line
    arranger.line_width.should.be > base_line_width
  end
end

describe "Core::Text::Formatted::Arranger#line" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world", :styles => [:bold] }]
    @arranger.format_array = array
    while string = @arranger.next_string
    end
  end
  it "should raise an error if called before finalize_line was called" do
    lambda do
      @arranger.line
    end.should.raise(RuntimeError)
  end
  it "should return the complete line" do
    @arranger.finalize_line
    @arranger.line.should == "hello world"
  end
end

describe "Core::Text::Formatted::Arranger#unconsumed" do
  it "should return the original array if nothing was consumed" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you now?" }]
    arranger.format_array = array
    arranger.unconsumed.should == array
  end
  it "should return an empty array if everything was consumed" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you now?" }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.unconsumed.should == []
  end
end

describe "Core::Text::Formatted::Arranger#finished" do
  it "should be false if anything was not printed" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you now?" }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.update_last_string(" you", "now?", nil)
    arranger.should.not.be.finished
  end
  it "should be false if everything was printed" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you now?" }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.should.be.finished
  end
end

describe "Core::Text::Formatted::Arranger.max_line_height" do
  it "should be the height of the maximum consumed fragment" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic],
               :size => 28 },
             { :text => " you now?" }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.finalize_line
    arranger.max_line_height.should.be.close(33.32, 0.0001)
  end
end

describe "Core::Text::Formatted::Arranger#repack_unretrieved" do
  it "should restore part of the original string" do
    create_pdf
    arranger = Prawn::Core::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :styles => [:bold] },
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you now?" }]
    arranger.format_array = array
    while string = arranger.next_string
    end
    arranger.finalize_line
    arranger.retrieve_fragment
    arranger.retrieve_fragment
    arranger.repack_unretrieved
    arranger.unconsumed.should == [
             { :text => "are", :styles => [:bold, :italic] },
             { :text => " you now?" }]
  end
end
