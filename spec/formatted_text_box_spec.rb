# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")


describe "Text::FormatArrayManager#format_array" do
  it "should populate unconsumed array" do
    formatter = Prawn::Text::FormatArrayManager.new
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
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "\nhello\nworld" }]
    formatter.format_array = array
    formatter.unconsumed[0].should == { :text => "\n" }
    formatter.unconsumed[1].should == { :text => "hello" }
    formatter.unconsumed[2].should == { :text => "\n" }
    formatter.unconsumed[3].should == { :text => "world" }
  end
end
describe "Text::FormatArrayManager#preview_next_string" do
  it "should not populate the consumed array" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello" }]
    formatter.format_array = array
    formatter.preview_next_string
    formatter.consumed.should == []
  end
  it "should not consumed array" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello" }]
    formatter.format_array = array
    formatter.preview_next_string.should == "hello"
  end
end
describe "Text::FormatArrayManager#next_string" do
  it "should populate consumed array" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.consumed[0].should == { :text => "hello " }
    formatter.consumed[1].should == { :text => "world how ",
                                              :style => [:bold] }
    formatter.consumed[2].should == { :text => "are",
                                              :style => [:bold, :italic] }
    formatter.consumed[3].should == { :text => " you?" }
  end
  it "should populate current_format_state array" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    counter = 0
    while !formatter.next_string.nil?
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
  it "should update current_font_style" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    counter = 0
    while !formatter.next_string.nil?
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

describe "Text::FormatArrayManager#retrieve_string" do
  it "should never return an empty string" do
    formatter = Prawn::Text::FormatArrayManager.new
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
    while !formatter.next_string.nil?
    end
    while string = formatter.retrieve_string
      string.should.not.be.empty
    end
    formatter.consumed.should.be.empty
  end
  it "should return the consumed strings in order of consumption and update" +
     " the retrieved_fontstyle to the state it was in at the time each" +
     " string was consumed" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
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
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.retrieve_string
    formatter.retrieve_string.should == "world how "
    formatter.last_retrieved_font_style.should == :bold
    formatter.current_font_style.should == :normal
  end
  it "should update last_retrieved_width" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    counter = 10
    while !formatter.next_string.nil?
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

describe "Text::FormatArrayManager#set_last_string_size_data" do
  it "should set the width of the last consumed string" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    counter = 10
    while !formatter.next_string.nil?
      formatter.set_last_string_size_data(:width => counter,
                                          :line_height => counter + 1,
                                          :descender => counter + 2,
                                          :ascender => counter + 3)
      counter += 10
    end
    formatter.consumed[0].should == { :text => "hello ",
                                              :width => 10 }
    formatter.consumed[1].should == { :text => "world how ",
                                              :style => [:bold],
                                              :width => 20 }
    formatter.consumed[2].should == { :text => "are",
                                              :style => [:bold, :italic],
                                              :width => 30 }
    formatter.consumed[3].should == { :text => " you?",
                                              :width => 40 }
  end
  it "should set the components of the line height to the maximum" +
     "values set since calling tokenize_string" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you?" }]
    formatter.format_array = array
    counter = 10
    while !formatter.next_string.nil?
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

describe "Text::FormatArrayManager#update_last_string" do
  it "should update the last retrieved string with what actually fit on" +
     "the line and the list of unconsumed with what did not" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?", :style => [:bold, :italic] }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.update_last_string(" you", " now?")
    formatter.consumed[3].should == { :text => " you",
                                      :style => [:bold, :italic] }
    formatter.unconsumed.should == [{ :text => " now?",
                                      :style => [:bold, :italic] }]
  end
  context "when the entire string was used" do
    it "should not push empty string onto unconsumed" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
      while !formatter.next_string.nil?
      end
      formatter.update_last_string(" you now?", "")
      formatter.unconsumed.should == []
    end
  end
end

describe "Text::FormatArrayManager#unconsumed" do
  it "should return the original array if nothing was consumed" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    formatter.unconsumed.should == array
  end
  it "should return an empty array if everything was consumed" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.unconsumed.should == []
  end
end

describe "Text::FormatArrayManager#finished" do
  it "should be false if anything was not printed" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.update_last_string(" you", "now?")
    formatter.should.not.be.finished
  end
  it "should be false if everything was printed" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.should.be.finished
  end
end

describe "Text::FormatArrayManager#unfinished" do
  it "should be false if anything was not printed" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.update_last_string(" you", "now?")
    formatter.should.be.unfinished
  end
  it "should be false if everything was printed" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.should.not.be.unfinished
  end
end

describe "Text::FormatArrayManager.max_line_height" do
  it "should be the height of the maximum consumed fragment" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.update_last_string(" you", "now?")
    formatter.should.be.unfinished
  end
end

describe "Text::FormatArrayManager#repack_unretrieved" do
  it "should restore part of the original string" do
    formatter = Prawn::Text::FormatArrayManager.new
    array = [{ :text => "hello " },
             { :text => "world how ", :style => [:bold] },
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
    formatter.format_array = array
    while !formatter.next_string.nil?
    end
    formatter.retrieve_string
    formatter.retrieve_string
    formatter.repack_unretrieved
    formatter.unconsumed.should == [
             { :text => "are", :style => [:bold, :italic] },
             { :text => " you now?" }]
  end
end

describe "Text::Formatted::Box#render" do
  it "should handle newlines" do
    create_pdf
    array = [{ :text => "hello\nworld"}]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\nworld"
  end
  it "should omit spaces from the beginning of the line" do
    create_pdf
    array = [{ :text => " hello\n world"}]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\nworld"
  end
  it "should omit spaces from the end of the line" do
    create_pdf
    array = [{ :text => "hello \nworld "}]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\nworld"
  end
end

describe "Text::Formatted::Box#height without leading" do
  it "should equal the sum of the height of each line" do
    create_pdf
    format_array = [{ :text => "line 1" },
                    { :text => "\n" },
                    { :text => "line 2" }]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render
    text_box.height.should == @pdf.font.height * 2
  end
end

describe "Text::Formatted::Box#height with leading" do
  it "should equal the sum of the height of each line" +
     " plus all but the last leading" do
    create_pdf
    format_array = [{ :text => "line 1" },
                    { :text => "\n" },
                    { :text => "line 2" }]
    leading = 12
    options = { :document => @pdf, :leading => leading }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render
    text_box.height.should == @pdf.font.height * 2 + leading
  end
end

describe "Text::Formatted::Box#render(:single_line => true)" do
  it "should draw only one line to the page" do
    create_pdf
    text = "Oh hai text rect. " * 10
    format_array = [:text => text]
    options = { :document => @pdf,
                 :single_line => true }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.strings.length.should == 1
  end
end

describe "Text::Formatted::Box#render(:dry_run => true)" do
  it "should not draw any content to the page" do
    create_pdf
    text = "Oh hai text rect. " * 10
    format_array = [:text => text]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render(:dry_run => true)
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.strings.should.be.empty
  end
  it "subsequent calls to render should not raise an ArgumentError exception" do
    create_pdf
    text = "™©"
    format_array = [:text => text]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render(:dry_run => true)
    lambda { text_box.render }.should.not.raise(ArgumentError)
  end
end

describe "Text::Formatted::Box#render" do
  it "should be able to set bold" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "bold", :style => [:bold] },
             { :text => " text" }]
    @pdf.formatted_text_box(array, :document => @pdf)
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    fonts = contents.font_settings.map { |e| e[:name] }
    fonts.should == [:Helvetica, :"Helvetica-Bold", :Helvetica]
    contents.strings[0].should == "this contains "
    contents.strings[1].should == "bold"
    contents.strings[2].should == " text"
  end
  it "should be able to set italics" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "italic", :style => [:italic] },
             { :text => " text" }]
    @pdf.formatted_text_box(array, :document => @pdf)
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    fonts = contents.font_settings.map { |e| e[:name] }
    fonts.should == [:Helvetica, :"Helvetica-Oblique", :Helvetica]
  end
  it "should be able to set compound bold and italic text" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "bold italic", :style => [:bold, :italic] },
             { :text => " text" }]
    @pdf.formatted_text_box(array, :document => @pdf)
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    fonts = contents.font_settings.map { |e| e[:name] }
    fonts.should == [:Helvetica, :"Helvetica-BoldOblique", :Helvetica]
  end
  it "should be able to set underline" do
  end
  it "should be able to set strikethrough" do
  end
  it "should be able to set links" do
  end
  it "should be able to set font size" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "sized", :size => 24 },
             { :text => " text" }]
    @pdf.move_cursor_to(@pdf.font.height)
    @pdf.formatted_text_box(array, :document => @pdf)
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.font_settings[0][:size].should == 12
    contents.font_settings[1][:size].should == 24
  end
  it "should set the baseline based on the tallest fragment on a given line" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "sized", :size => 24 },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    @pdf.font_size(24) do
      text_box.height.should.be.close(@pdf.font.height, 0.001)
    end
  end
  it "should be able to set color" do
  end
end

describe "Text::Formatted::Box with text than can fit in the box" do
  before(:each) do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @format_array = [:text => @text]
    @options = {
      :width => 162.0,
      :height => 162.0,
      :document => @pdf
    }
  end
  
  it "printed text should match requested text, except for trailing or" +
     " leading white space and that spaces may be replaced by newlines" do
    text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    text_box.render
    text_box.text.gsub("\n", " ").should == @text.strip
  end
  
  it "render should return an empty array because no text remains unprinted" do
    text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    text_box.render.should == []
  end

  it "should be truncated when the leading is set high enough to prevent all" +
     " the lines from being printed" do
    @options[:leading] = 40
    text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    text_box.render
    text_box.text.gsub("\n", " ").should.not == @text.strip
  end
end

describe "Text::Formatted::Box printing UTF-8 string with higher bit characters with" +
         " inline styling" do
  before(:each) do
    create_pdf    
    @text = "©"
    format_array = [:text => @text]
    # not enough height to print any text, so we can directly compare against
    # the input string
    bounding_height = 1.0
    options = {
      :height => bounding_height,
      :document => @pdf
    }
    @text_box = Prawn::Text::Formatted::Box.new(format_array, options)
  end
  describe "when using a TTF font" do
    before(:each) do
      file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
      @pdf.font_families["Action Man"] = {
        :normal      => { :file => file, :font => "ActionMan" },
        :italic      => { :file => file, :font => "ActionMan-Italic" },
        :bold        => { :file => file, :font => "ActionMan-Bold" },
        :bold_italic => { :file => file, :font => "ActionMan-BoldItalic" }
      }
    end
    it "unprinted text should be in UTF-8 encoding" do
      @pdf.font("Action Man")
      remaining_text = @text_box.render
      remaining_text.first[:text].should == @text
    end
    it "subsequent calls to Text::Formatted::Box need not include the" +
       " :skip_encoding => true option" do
      @pdf.font("Action Man")
      remaining_text = @text_box.render
      lambda {
        @pdf.formatted_text_box(remaining_text, :document => @pdf)
      }.should.not.raise(ArgumentError)
    end
  end
  describe "when using an AFM font" do
    it "unprinted text should be in WinAnsi encoding" do
      remaining_text = @text_box.render
      remaining_text.first[:text].should == @pdf.font.normalize_encoding(@text)
    end
    it "subsequent calls to Text::Formatted::Box must include the" +
       " :skip_encoding => true option" do
      remaining_text = @text_box.render
      lambda {
        @pdf.formatted_text_box(remaining_text, :document => @pdf)
      }.should.raise(ArgumentError)
      lambda {
        @pdf.formatted_text_box(remaining_text, :document => @pdf,
                                :skip_encoding => true)
      }.should.not.raise(ArgumentError)
    end
  end
end
          

describe "Text::Formatted::Box with more text than can fit in the box" do
  before(:each) do
    create_pdf    
    @text = "Oh hai text rect. " * 30
    @format_array = [:text => @text]
    @bounding_height = 162.0
    @options = {
      :width => 162.0,
      :height => @bounding_height,
      :document => @pdf
    }
  end

  context "truncated overflow" do
    before(:each) do
      @options[:overflow] = :truncate
      @text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    end
    it "should be truncated" do
      @text_box.render
      @text_box.text.gsub("\n", " ").should.not == @text.strip
    end
    it "render should not return an empty string because some text remains" +
      " unprinted" do
      @text_box.render.should.not == ""
    end
    it "#height should be no taller than the specified height" do
      @text_box.render
      @text_box.height.should.be <= @bounding_height
    end
    it "#height should be within one font height of the specified height" do
      @text_box.render
      @text_box.height.should.be.close(@bounding_height, @pdf.font.height)
    end
  end
  
  context "ellipses overflow" do
    it "should raise NotImplementedError" do
      @options[:overflow] = :ellipses
      lambda {
        Prawn::Text::Formatted::Box.new(@format_array, @options)
      }.should.raise(NotImplementedError)
    end
  end

  context "expand overflow" do
    before(:each) do
      @options[:overflow] = :expand
      @text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    end
    it "height should expand to encompass all the text (but not exceed the" +
      "height of the page)" do
      @text_box.render
      @text_box.height.should > @bounding_height
    end
    it "should display the entire string (as long as there was space" +
      " remaining on the page to print all the text)" do
      @text_box.render
      @text_box.text.gsub("\n", " ").should == @text.strip
    end
    it "render should return an empty array because no text remains" +
      " unprinted(as long as there was space remaining on the page to" +
      " print all the text)" do
      @text_box.render.should == []
    end
  end

  context "shrink_to_fit overflow" do
    before(:each) do
      @options[:overflow] = :shrink_to_fit
      @options[:min_font_size] = 2
      @text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    end
    it "should display the entire text" do
      @text_box.render
      @text_box.text.gsub("\n", " ").should == @text.strip
    end
    it "render should return an empty array because no text" +
      " remains unprinted" do
      @text_box.render.should == []
    end
  end
end

describe 'Text::Formatted::Box wrapping' do
  before(:each) do
    create_pdf
  end

  it "should wrap text" do
    text = "Please wrap this text about HERE. More text that should be wrapped"
    format_array = [:text => text]
    expect = "Please wrap this text about\nHERE. " +
      "More text that should be\nwrapped"

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 220,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect end of line when wrapping text" do
    text = "Please wrap only before\nTHIS word. Don't wrap this"
    format_array = [:text => text]
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 220,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect multiple newlines when wrapping text" do
    text = "Please wrap only before THIS\n\nword. Don't wrap this"
    format_array = [:text => text]
    expect= "Please wrap only before\nTHIS\n\nword. Don't wrap this"

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 200,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect multiple newlines when wrapping text when those newlines" +
    " coincide with a line break" do
    text = "Please wrap only before\n\nTHIS word. Don't wrap this"
    format_array = [:text => text]
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 220,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect initial newlines" do
    text = "\nThis should be on line 2"
    format_array = [:text => text]
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 220,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should wrap lines comprised of a single word of the bounds when" +
    " wrapping text" do
    text = "You_can_wrap_this_text_HERE"
    format_array = [:text => text]
    expect = "You_can_wrap_this_text_HE\nRE"

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 180,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should wrap lines comprised of a single word of the bounds when" +
    " wrapping text" do
    text = '©' * 30
    format_array = [:text => text]

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array, :width => 180,
                                             :overflow => :expand,
                                             :document => @pdf)

    text_box.render

    expected = '©'*25 + "\n" + '©' * 5
    @pdf.font.normalize_encoding!(expected)

    text_box.text.should == expected
  end

  it "should wrap non-unicode strings using single-byte word-wrapping" do
    text = "continúa esforzandote " * 5
    format_array = [:text => text]
    text_box = Prawn::Text::Formatted::Box.new(format_array, :width => 180,
                                             :document => @pdf)
    text_box.render
    results_with_accent = text_box.text

    text = "continua esforzandote " * 5
    format_array = [:text => text]
    text_box = Prawn::Text::Formatted::Box.new(format_array, :width => 180,
                                             :document => @pdf)
    text_box.render
    no_accent = text_box.text

    results_with_accent.first_line.length.should == no_accent.first_line.length
  end
  
end

def reduce_precision(float)
  ("%.5f" % float).to_f
end
