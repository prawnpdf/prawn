require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::InlineFormatter#tokenize_string" do
  it "should break the string into tokens" do
    formatter = Prawn::Text::InlineFormatter.new
    tokens = formatter.tokenize_string("hello <b>world\nhow <i>are</i></b> you?")
    tokens.should == ["hello ",
                      "<b>",
                      "world",
                      "\n",
                      "how ",
                      "<i>",
                      "are",
                      "</i>",
                      "</b>",
                      " you?"]
  end
end

describe "Text::InlineFormatter#next_string" do
  it "should populate format_state and consumed_strings" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you?")
    while formatter.next_string != ""
    end
    formatter.current_format_state.should == []
    formatter.consumed_strings[0].should == { :string => "hello ",
                                              :format => [],
                                              :tags => [] }
    formatter.consumed_strings[1].should == { :string => "world how ",
                                              :format => [:bold],
                                              :tags => ["<b>"] }
    formatter.consumed_strings[2].should == { :string => "are",
                                              :format => [:bold, :italic],
                                              :tags => ["<i>"] }
    formatter.consumed_strings[3].should == { :string => " you?",
                                              :format => [],
                                              :tags => ["</i>", "</b>"] }
  end
  context "when encountering a newline" do
    it "should return a newline" do
      formatter = Prawn::Text::InlineFormatter.new
      formatter.tokenize_string("hello <b>world\nhow <i>are</i></b> you?")
      formatter.next_string.should == "hello "
      formatter.next_string.should == "world"
      formatter.next_string.should == "\n"
    end
    it "should not add the newline to consumed_strings" do
      formatter = Prawn::Text::InlineFormatter.new
      formatter.tokenize_string("hello <b>world\nhow <i>are</i></b> you?")
      formatter.next_string
      formatter.next_string
      formatter.next_string
      formatter.consumed_strings.last.should == { :string => "world",
                                              :format => [:bold],
                                              :tags => ["<b>"] }
    end
  end
  it "should update current_font_style" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you?")
    counter = 0
    while formatter.next_string != ""
      case counter
      when 0
        formatter.current_font_style.should == :normal
      when 1
        formatter.current_font_style.should == :bold
      when 2
        formatter.current_font_style.should == :bold_italic
      when 3
        formatter.current_font_style.should == :normal
      end
      counter += 1
    end
  end
end

describe "Text::InlineFormatter#retrieve_string" do
  it "should return the consumed strings in order of consumption and update" +
     " the retrieved_fontstyle to the state it was in at the time each" +
     " string was consumed" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you?")
    while formatter.next_string != ""
    end
    formatter.retrieve_string.should == "hello "
    formatter.last_retrieved_font_style.should == :normal
    
    formatter.retrieve_string.should == "world how "
    formatter.last_retrieved_font_style.should == :bold
    
    formatter.retrieve_string.should == "are"
    formatter.last_retrieved_font_style.should == :bold_italic
    
    formatter.retrieve_string.should == " you?"
    formatter.last_retrieved_font_style.should == :normal
  end
  it "should not alter the current font style" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you?")
    while formatter.next_string != ""
    end
    formatter.retrieve_string
    formatter.retrieve_string.should == "world how "
    formatter.last_retrieved_font_style.should == :bold
    formatter.current_font_style.should == :normal
  end
  it "should update last_retrieved_width" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you?")
    counter = 10
    while formatter.next_string != ""
      formatter.set_last_string_size_data(:width => counter,
                                          :line_height => counter + 1,
                                          :descender => counter + 2,
                                          :ascender => counter + 3)
      counter += 10
    end
    formatter.retrieve_string
    formatter.retrieve_string
    formatter.last_retrieved_width.should == 20
  end
end

describe "Text::InlineFormatter#set_last_string_size_data" do
  it "should set the width of the last consumed string" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you?")
    counter = 10
    while formatter.next_string != ""
      formatter.set_last_string_size_data(:width => counter,
                                          :line_height => counter + 1,
                                          :descender => counter + 2,
                                          :ascender => counter + 3)
      counter += 10
    end
    formatter.consumed_strings[0].should == { :string => "hello ",
                                              :format => [],
                                              :tags => [],
                                              :width => 10 }
    formatter.consumed_strings[1].should == { :string => "world how ",
                                              :format => [:bold],
                                              :tags => ["<b>"],
                                              :width => 20 }
    formatter.consumed_strings[2].should == { :string => "are",
                                              :format => [:bold, :italic],
                                              :tags => ["<i>"],
                                              :width => 30 }
    formatter.consumed_strings[3].should == { :string => " you?",
                                              :format => [],
                                              :tags => ["</i>", "</b>"],
                                              :width => 40 }
  end
  it "should set the components of the line height to the maximum" +
     "values set since calling tokenize_string" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you?")
    counter = 10
    while formatter.next_string != ""
      formatter.set_last_string_size_data(:width => counter,
                                          :line_height => counter + 1,
                                          :descender => counter + 2,
                                          :ascender => counter + 3)
      counter += 10
    end
    formatter.max_line_height.should == 41
    formatter.max_descender.should == 42
    formatter.max_ascender.should == 43
  end
end

describe "Text::InlineFormatter#update_last_string" do
  it "should update the last retrieved string with what actually fit on" +
     "the line and the list of tokens with what did not" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you now?")
    while formatter.next_string != ""
    end
    formatter.update_last_string(" you", " now?")
    formatter.consumed_strings[3].should == { :string => " you",
                                              :format => [],
                                              :tags => ["</i>", "</b>"] }
    formatter.tokens.should == [" now?"]
  end
  context "when the entire string was used" do
    it "should not push empty string onto tokens" do
      formatter = Prawn::Text::InlineFormatter.new
      formatter.tokenize_string("hello <b>world how <i>are</i></b> you now?")
      while formatter.next_string != ""
      end
      formatter.update_last_string(" you now?", "")
      formatter.tokens.should == []
    end
  end
end

describe "Text::InlineFormatter#unconsumed_string" do
  it "should return the original string" +
     "if nothing was consumed" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you now?")
    formatter.unconsumed_string.should == "hello <b>world how <i>are</i></b> you now?"
  end
  it "should return an empty string if everything was consumed" do
    formatter = Prawn::Text::InlineFormatter.new
    string = "hello <b>world how <i>are</i></b> you now?"
    formatter.tokenize_string(string)
    while formatter.next_string != ""
    end
    formatter.unconsumed_string.should == ""
  end
end

describe "Text::InlineFormatter#finished" do
  it "should be false if anything was not printed" do
    formatter = Prawn::Text::InlineFormatter.new
    string = "hello <b>world how <i>are</i></b> you now?"
    formatter.tokenize_string(string)
    while formatter.next_string != ""
    end
    formatter.update_last_string(" you", "now?")
    formatter.should.not.be.finished
  end
  it "should be false if everything was printed" do
    formatter = Prawn::Text::InlineFormatter.new
    string = "hello <b>world how <i>are</i></b> you now?"
    formatter.tokenize_string(string)
    while formatter.next_string != ""
    end
    formatter.should.be.finished
  end
end

describe "Text::InlineFormatter#unfinished" do
  it "should be false if anything was not printed" do
    formatter = Prawn::Text::InlineFormatter.new
    string = "hello <b>world how <i>are</i></b> you now?"
    formatter.tokenize_string(string)
    while formatter.next_string != ""
    end
    formatter.update_last_string(" you", "now?")
    formatter.should.be.unfinished
  end
  it "should be false if everything was printed" do
    formatter = Prawn::Text::InlineFormatter.new
    string = "hello <b>world how <i>are</i></b> you now?"
    formatter.tokenize_string(string)
    while formatter.next_string != ""
    end
    formatter.should.not.be.unfinished
  end
end

describe "Text::InlineFormatter.max_line_height" do
  it "should be the height of the maximum consumed fragment" do
    formatter = Prawn::Text::InlineFormatter.new
    string = "hello <b>world how <i>are</i></b> you now?"
    formatter.tokenize_string(string)
    while formatter.next_string != ""
    end
    formatter.update_last_string(" you", "now?")
    formatter.should.be.unfinished
  end
end

describe "Text::InlineFormatter#repack_unretrieved_strings" do
  it "should restore part of the original string" do
    formatter = Prawn::Text::InlineFormatter.new
    formatter.tokenize_string("hello <b>world how <i>are</i></b> you?")
    while formatter.next_string != ""
    end
    formatter.retrieve_string
    formatter.retrieve_string
    formatter.repack_unretrieved_strings
    formatter.unconsumed_string.should == "<i>are</i></b> you?"
  end
end
