# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Formatted::Arranger#format_array" do
  it "should populate unconsumed array" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    formatter.unconsumed[0].should == { :text => "hello " }
    formatter.unconsumed[1].should == { :text => "world how ",
                                              :style => [:bold] }
    formatter.unconsumed[2].should == { :text => "are",
                                              :style => [:bold, :italic] }
    formatter.unconsumed[3].should == { :text => " you?" }
  end
  it "should split newlines into their own elements" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "\nhello\nworld" }]
    formatter.format_array = array
    formatter.unconsumed[0].should == { :text => "\n" }
    formatter.unconsumed[1].should == { :text => "hello" }
    formatter.unconsumed[2].should == { :text => "\n" }
    formatter.unconsumed[3].should == { :text => "world" }
  end
end
describe "Text::Formatted::Arranger#preview_next_string" do
  it "should not populate the consumed array" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello" }]
    formatter.format_array = array
    formatter.preview_next_string
    formatter.consumed.should == []
  end
  it "should not consumed array" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello" }]
    formatter.format_array = array
    formatter.preview_next_string.should == "hello"
  end
end
describe "Text::Formatted::Arranger#next_string" do
  it "should populate consumed array" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.consumed[0].should == { :text => "hello " }
    formatter.consumed[1].should == { :text => "world how ",
                                              :style => [:bold] }
    formatter.consumed[2].should == { :text => "are",
                                              :style => [:bold, :italic] }
    formatter.consumed[3].should == { :text => " you?" }
  end
  it "should populate current_format_state array" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    counter = 0
    while string = formatter.next_string
      case counter
      when 0
        formatter.current_format_state.should == { }
      when 1
        formatter.current_format_state.should == { :style => [:bold] }
      when 2
        formatter.current_format_state.should == { :style => [:bold, :italic] }
      when 3
        formatter.current_format_state.should == { }
      end
      counter += 1
    end
  end
end

describe "Text::Formatted::Arranger#retrieve_string" do
  it "should never return an empty string" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello\nworld\n\n\nhow are you?" },
             { :text => "\n" },
             { :text => "\n" },
             { :text => "\n" },
             { :text => "" },
             { :text => "fine, thanks." },
             { :text => "" },
             { :text => "\n" },
             { :text => "" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    while string = formatter.retrieve_string
      string.should.not.be.empty
    end
    formatter.consumed.should.be.empty
  end
  it "should return the consumed strings in order of consumption and update" +
     " the retrieved_format_state to the state it was in at the time each" +
     " string was consumed" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.retrieve_string.should == "hello "
    formatter.retrieved_format_state[:style].should.be.nil
    
    formatter.retrieve_string.should == "world how "
    formatter.retrieved_format_state[:style].should == [:bold]
    
    formatter.retrieve_string.should == "are"
    formatter.retrieved_format_state[:style].should == [:bold, :italic]
    
    formatter.retrieve_string.should == " you?"
    formatter.retrieved_format_state[:style].should.be.nil
  end
  it "should not alter the current font style" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.retrieve_string
    formatter.retrieve_string.should == "world how "
    formatter.retrieved_format_state[:style].should == [:bold]
    formatter.current_format_state[:style].should.be.nil
  end
end

describe "Text::Formatted::Arranger#update_last_string" do
  it "should update the last retrieved string with what actually fit on" +
     "the line and the list of unconsumed with what did not" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?", :style => [:bold, :italic] }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.update_last_string(" you", " now?")
    formatter.consumed[3].should == { :text => " you",
                                      :style => [:bold, :italic] }
    formatter.unconsumed.should == [{ :text => " now?",
                                      :style => [:bold, :italic] }]
  end
  context "when the entire string was used" do
    it "should not push empty string onto unconsumed" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
      while string = formatter.next_string
      end
      formatter.update_last_string(" you now?", "")
      formatter.unconsumed.should == []
    end
  end
end
describe "Text::Formatted::Arranger#space_count" do
  it "should return the total number of spaces in all fragments" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.space_count.should == 4
  end
end
describe "Text::Formatted::Arranger#finalize_line" do
  it "should make it so the last consumed fragment ends with non-white-space" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "   ", :style => [:bold, :italic] }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.finalize_line
    formatter.consumed.length.should == 2
  end
  it "should update space_count" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "   ", :style => [:bold, :italic] }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.finalize_line
    formatter.space_count.should == 2
  end
  it "should update line width" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.finalize_line
    formatter.line_width.should.be > 0
  end
end

describe "Text::Formatted::Arranger#line" do
  it "should return the complete line" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world", :style => [:bold] }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.line.should == "hello world"
  end
end

describe "Text::Formatted::Arranger#unconsumed" do
  it "should return the original array if nothing was consumed" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    formatter.unconsumed.should == array
  end
  it "should return an empty array if everything was consumed" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.unconsumed.should == []
  end
end

describe "Text::Formatted::Arranger#finished" do
  it "should be false if anything was not printed" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.update_last_string(" you", "now?")
    formatter.should.not.be.finished
  end
  it "should be false if everything was printed" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.should.be.finished
  end
end

describe "Text::Formatted::Arranger#unfinished" do
  it "should be false if anything was not printed" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.update_last_string(" you", "now?")
    formatter.should.be.unfinished
  end
  it "should be false if everything was printed" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.should.not.be.unfinished
  end
end

describe "Text::Formatted::Arranger.max_line_height" do
  it "should be the height of the maximum consumed fragment" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.update_last_string(" you", "now?")
    formatter.should.be.unfinished
  end
end

describe "Text::Formatted::Arranger#repack_unretrieved" do
  it "should restore part of the original string" do
    create_pdf
    formatter = Prawn::Text::Formatted::Arranger.new(@pdf)
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while string = formatter.next_string
    end
    formatter.retrieve_string
    formatter.retrieve_string
    formatter.repack_unretrieved
    formatter.unconsumed.should == [
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
  end
end
