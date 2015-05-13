# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Core::Text::Formatted::LineWrap#wrap_line" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    @line_wrap = Prawn::Text::Formatted::LineWrap.new
    @one_word_width = 50
  end
  it "should strip leading and trailing spaces" do
    array = [{ :text => " hello world, " },
             { :text => "goodbye  ", :style => [:bold] }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => 300,
                                  :document => @pdf)
    expect(string).to eq("hello world, goodbye")
  end
  it "should strip trailing spaces when a white-space-only fragment was" \
     " successfully pushed onto the end of a line but no other non-white" \
     " space fragment fits after it" do
    array = [{ :text => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa " },
             { :text => "  ", :style => [:bold] },
             { :text => " bbbbbbbbbbbbbbbbbbbbbbbbbbbb" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => 300,
                                  :document => @pdf)
    expect(string).to eq("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
  end
  it "should raise_error CannotFit if a too-small width is given" do
    array = [{ :text => " hello world, " },
             { :text => "goodbye  ", :style => [:bold] }]
    @arranger.format_array = array
    expect do
      @line_wrap.wrap_line(:arranger => @arranger,
                           :width => 1,
                           :document => @pdf)
    end.to raise_error(Prawn::Errors::CannotFit)
  end

  it "should break on space" do
    array = [{ :text => "hello world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello")
  end

  it "should break on zero-width space" do
    @pdf.font("#{Prawn::DATADIR}/fonts/DejaVuSans.ttf")
    array = [{ :text => "hello#{Prawn::Text::ZWSP}world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello")
  end

  it "should not display zero-width space" do
    @pdf.font("#{Prawn::DATADIR}/fonts/DejaVuSans.ttf")
    array = [{ :text => "hello#{Prawn::Text::ZWSP}world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => 300,
                                  :document => @pdf)
    expect(string).to eq("helloworld")
  end

  it "should break on tab" do
    array = [{ :text => "hello\tworld" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello")
  end

  it "should break on hyphens" do
    array = [{ :text => "hello-world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello-")
  end

  it "should not break after a hyphen that follows white space and" \
     "precedes a word" do
    array = [{ :text => "hello -" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello -")

    array = [{ :text => "hello -world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello")
  end

  it "should break on a soft hyphen" do
    string = @pdf.font.normalize_encoding("hello#{Prawn::Text::SHY}world")
    array = [{ :text => string }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expected = @pdf.font.normalize_encoding("hello#{Prawn::Text::SHY}")
    expected.force_encoding(Encoding::UTF_8)
    expect(string).to eq(expected)

    @pdf.font("#{Prawn::DATADIR}/fonts/DejaVuSans.ttf")
    @line_wrap = Prawn::Text::Formatted::LineWrap.new

    string = "hello#{Prawn::Text::SHY}world"
    array = [{ :text => string }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello#{Prawn::Text::SHY}")
  end

  it "should ignore width of a soft-hyphen during adding fragments to line", :issue => 775 do
    hyphen_string = "Hy#{Prawn::Text::SHY}phe#{Prawn::Text::SHY}nat#{Prawn::Text::SHY}ions "
    string1 = @pdf.font.normalize_encoding(hyphen_string * 5)
    string2 = @pdf.font.normalize_encoding("Hyphenations " * 3 + hyphen_string)

    array1 = [{ text: string1 }]
    array2 = [{ text: string2 }]

    @arranger.format_array = array1

    res1 = @line_wrap.wrap_line(:arranger => @arranger,
                                :width => 300,
                                :document => @pdf)

    @line_wrap = Prawn::Text::Formatted::LineWrap.new

    @arranger.format_array = array2

    res2 = @line_wrap.wrap_line(:arranger => @arranger,
                                :width => 300,
                                :document => @pdf)
    expect(res1).to eq(res2)
  end

  it "should not display soft hyphens except at the end of a line " \
     "for more than one element in format_array", :issue => 347 do
    @pdf.font("#{Prawn::DATADIR}/fonts/DejaVuSans.ttf")
    @line_wrap = Prawn::Text::Formatted::LineWrap.new

    string1 = @pdf.font.normalize_encoding("hello#{Prawn::Text::SHY}world ")
    string2 = @pdf.font.normalize_encoding("hi#{Prawn::Text::SHY}earth")
    array = [{ :text => string1 }, { :text => string2 }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => 300,
                                  :document => @pdf)
    expect(string).to eq("helloworld hiearth")
  end

  it "should not break before a hard hyphen that follows a word" do
    enough_width_for_hello_world = 60

    array = [{ :text => "hello world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => enough_width_for_hello_world,
                                  :document => @pdf)
    expect(string).to eq("hello world")

    array = [{ :text => "hello world-" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => enough_width_for_hello_world,
                                  :document => @pdf)
    expect(string).to eq("hello")

    @pdf.font("#{Prawn::DATADIR}/fonts/DejaVuSans.ttf")
    @line_wrap = Prawn::Text::Formatted::LineWrap.new
    enough_width_for_hello_world = 68

    array = [{ :text => "hello world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => enough_width_for_hello_world,
                                  :document => @pdf)
    expect(string).to eq("hello world")

    array = [{ :text => "hello world-" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => enough_width_for_hello_world,
                                  :document => @pdf)
    expect(string).to eq("hello")
  end

  it "should not break after a hard hyphen that follows a soft hyphen and" \
    "precedes a word" do
    string = @pdf.font.normalize_encoding("hello#{Prawn::Text::SHY}-")
    array = [{ :text => string }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello-")

    string = @pdf.font.normalize_encoding("hello#{Prawn::Text::SHY}-world")
    array = [{ :text => string }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expected = @pdf.font.normalize_encoding("hello#{Prawn::Text::SHY}")
    expected.force_encoding(Encoding::UTF_8)
    expect(string).to eq(expected)

    @pdf.font("#{Prawn::DATADIR}/fonts/DejaVuSans.ttf")
    @line_wrap = Prawn::Text::Formatted::LineWrap.new

    string = "hello#{Prawn::Text::SHY}-"
    array = [{ :text => string }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello-")

    string = "hello#{Prawn::Text::SHY}-world"
    array = [{ :text => string }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    expect(string).to eq("hello#{Prawn::Text::SHY}")
  end

  it "should process UTF-8 chars", :unresolved, :issue => 693 do
    array = [{ :text => "Ｔｅｓｔ" }]
    @arranger.format_array = array

    # Should not raise an encoding error
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => 300,
                                  :document => @pdf)
    expect(string).to eq("Ｔｅｓｔ")
  end
end

describe "Core::Text::Formatted::LineWrap#space_count" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    @line_wrap = Prawn::Text::Formatted::LineWrap.new
  end
  it "should return the number of spaces in the last wrapped line" do
    array = [{ :text => "hello world, " },
             { :text => "goodbye", :style => [:bold] }]
    @arranger.format_array = array
    @line_wrap.wrap_line(:arranger => @arranger,
                         :width => 300,
                         :document => @pdf)
    expect(@line_wrap.space_count).to eq(2)
  end
  it "should exclude preceding and trailing spaces from the count" do
    array = [{ :text => " hello world, " },
             { :text => "goodbye  ", :style => [:bold] }]
    @arranger.format_array = array
    @line_wrap.wrap_line(:arranger => @arranger,
                         :width => 300,
                         :document => @pdf)
    expect(@line_wrap.space_count).to eq(2)
  end
end

describe "Core::Text::Formatted::LineWrap" do
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
  it "should only return an empty string if nothing fit or there" \
     "was nothing to wrap" do
    8.times do
      line = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => 200,
                                  :document => @pdf)
      expect(line).not_to be_empty
    end
    line = @line_wrap.wrap_line(:arranger => @arranger,
                                :width => 200,
                                :document => @pdf)
    expect(line).to be_empty
  end
  it "should tokenize a string using the scan_pattern" do
    tokens = @line_wrap.tokenize("one two three")
    expect(tokens.length).to eq(6)
  end
end

describe "Core::Text::Formatted::LineWrap#paragraph_finished?" do
  before(:each) do
    create_pdf
    @arranger = Prawn::Text::Formatted::Arranger.new(@pdf)
    @line_wrap = Prawn::Text::Formatted::LineWrap.new
    @one_word_width = 50
  end
  it "should be_false when the last printed line is not the end of the paragraph" do
    array = [{ :text => "hello world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)

    expect(@line_wrap.paragraph_finished?).to eq(false)
  end
  it "should be_true when the last printed line is the last fragment to print" do
    array = [{ :text => "hello world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)

    expect(@line_wrap.paragraph_finished?).to eq(true)
  end
  it "should be_true when a newline exists on the current line" do
    array = [{ :text => "hello\n world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)

    expect(@line_wrap.paragraph_finished?).to eq(true)
  end
  it "should be_true when a newline exists in the next fragment" do
    array = [{ :text => "hello " },
             { :text => " \n" },
             { :text => "world" }]
    @arranger.format_array = array
    string = @line_wrap.wrap_line(:arranger => @arranger,
                                  :width => @one_word_width,
                                  :document => @pdf)

    expect(@line_wrap.paragraph_finished?).to eq(true)
  end
end
