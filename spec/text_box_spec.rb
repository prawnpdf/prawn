# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Box#nothing_printed?" do
  it "should be_true when nothing printed" do
    create_pdf
    string = "Hello world, how are you?\nI'm fine, thank you."
    text_box = Prawn::Text::Box.new(string,
                                    :height => 2,
                                    :document => @pdf)
    text_box.render
    expect(text_box.nothing_printed?).to be_true
  end
  it "should be_false when something printed" do
    create_pdf
    string = "Hello world, how are you?\nI'm fine, thank you."
    text_box = Prawn::Text::Box.new(string,
                                    :height => 14,
                                    :document => @pdf)
    text_box.render
    expect(text_box.nothing_printed?).to be_false
  end
end

describe "Text::Box#everything_printed?" do
  it "should be_false when not everything printed" do
    create_pdf
    string = "Hello world, how are you?\nI'm fine, thank you."
    text_box = Prawn::Text::Box.new(string,
                                    :height => 14,
                                    :document => @pdf)
    text_box.render
    expect(text_box.everything_printed?).to be_false
  end
  it "should be_true when everything printed" do
    create_pdf
    string = "Hello world, how are you?\nI'm fine, thank you."
    text_box = Prawn::Text::Box.new(string,
                                    :document => @pdf)
    text_box.render
    expect(text_box.everything_printed?).to be_true
  end
end

describe "Text::Box#line_gap" do
  it "should == the line gap of the font when using a single " \
    "font and font size" do
    create_pdf
    string = "Hello world, how are you?\nI'm fine, thank you."
    text_box = Prawn::Text::Box.new(string,
                                    :document => @pdf)
    text_box.render
    expect(text_box.line_gap).to be_within(0.0001).of(@pdf.font.line_gap)
  end
end

describe "Text::Box" do
  it "should be able to set text direction document-wide" do
    create_pdf
    @pdf.text_direction(:rtl)
    @pdf.text_direction = :rtl
    string = "Hello world, how are you?\nI'm fine, thank you."
    text_box = Prawn::Text::Box.new(string,
                                    :document => @pdf)
    text_box.render
    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.strings[0]).to eq("?uoy era woh ,dlrow olleH")
    expect(text.strings[1]).to eq(".uoy knaht ,enif m'I")
  end

  it "should be able to reverse multi-byte text" do
    create_pdf
    @pdf.text_direction(:rtl)
    @pdf.text_direction = :rtl
    @pdf.text_direction = :rtl
    @pdf.font("#{Prawn::DATADIR}/fonts/gkai00mp.ttf", :size => 16) do
      @pdf.text "写个小"
    end
    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.strings[0]).to eq("小个写")
  end

  it "option should be able to override document-wide text direction" do
    create_pdf
    @pdf.text_direction = :rtl
    string = "Hello world, how are you?\nI'm fine, thank you."
    text_box = Prawn::Text::Box.new(string,
                                    :document => @pdf,
                                    :direction => :ltr)
    text_box.render
    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.strings[0]).to eq("Hello world, how are you?")
    expect(text.strings[1]).to eq("I'm fine, thank you.")
  end
end

describe "Text::Box" do
  it "should be able to set leading document-wide" do
    create_pdf
    @pdf.default_leading(7)
    @pdf.default_leading = 7
    text_box = Prawn::Text::Box.new("hello world",
                                    :document => @pdf)
    expect(text_box.leading).to eq(7)
  end

  it "option should be able to override document-wide leading" do
    create_pdf
    @pdf.default_leading = 7
    text_box = Prawn::Text::Box.new("hello world",
                                    :document => @pdf,
                                    :leading => 20)
    expect(text_box.leading).to eq(20)
  end
  it "should default to document-wide leading if no" \
    "leading option is provided" do
  end
end

describe "Text::Box#render with :align => :justify" do
  it "should draw the word spacing to the document" do
    create_pdf
    string = "hello world " * 20
    options = { :document => @pdf, :align => :justify }
    text_box = Prawn::Text::Box.new(string, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.word_spacing[0]).to be > 0
  end
  it "should not justify the last line of a paragraph" do
    create_pdf
    string = "hello world "
    options = { :document => @pdf, :align => :justify }
    text_box = Prawn::Text::Box.new(string, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.word_spacing).to be_empty
  end
end

describe "Text::Box" do
  it "should only require enough space for the descender and the ascender " \
     "when determining whether a line can fit" do
    create_pdf
    text = "Oh hai text rect"
    options = { :document => @pdf, :height => @pdf.font.ascender + @pdf.font.descender }
    text_box = Prawn::Text::Box.new(text, options)
    text_box.render
    expect(text_box.text).to eq("Oh hai text rect")

    text = "Oh hai text rect\nOh hai text rect"
    options = { :document => @pdf, :height => @pdf.font.height + @pdf.font.ascender + @pdf.font.descender }
    text_box = Prawn::Text::Box.new(text, options)
    text_box.render
    expect(text_box.text).to eq("Oh hai text rect\nOh hai text rect")
  end
end

describe "Text::Box#height without leading" do
  it "should == the sum of the height of each line, " \
    "not including the space below the last line" do
    create_pdf
    text = "Oh hai text rect.\nOh hai text rect."
    options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(text, options)
    text_box.render
    expect(text_box.height).to be_within(0.001).of(@pdf.font.height * 2 - @pdf.font.line_gap)
  end
end

describe "Text::Box#height with leading" do
  it "should == the sum of the height of each line plus leading, " \
    "but not including the space below the last line" do
    create_pdf
    text = "Oh hai text rect.\nOh hai text rect."
    leading = 12
    options = { :document => @pdf, :leading => leading }
    text_box = Prawn::Text::Box.new(text, options)
    text_box.render
    expect(text_box.height).to be_within(0.001).of((@pdf.font.height + leading) * 2 - @pdf.font.line_gap - leading)
  end
end

describe "Text::Box with :draw_text_callback" do
  before(:each) { create_pdf }

  it "hits the callback whenever text is drawn" do
    draw_block = stub
    draw_block.expects(:kick).with("this text is long enough to")
    draw_block.expects(:kick).with("span two lines")

    @pdf.text_box "this text is long enough to span two lines",
                  :width => 150,
                  :draw_text_callback => lambda { |text, _| draw_block.kick(text) }
  end

  it "hits the callback once per fragment for :inline_format" do
    draw_block = stub
    draw_block.expects(:kick).with("this text has ")
    draw_block.expects(:kick).with("fancy")
    draw_block.expects(:kick).with(" formatting")

    @pdf.text_box "this text has <b>fancy</b> formatting",
                  :inline_format => true, :width => 500,
                  :draw_text_callback => lambda { |text, _| draw_block.kick(text) }
  end

  it "does not call #draw_text!" do
    @pdf.expects(:draw_text!).never
    @pdf.text_box "some text", :width => 500,
                               :draw_text_callback => lambda { |_, _| }
  end
end

describe "Text::Box#valid_options" do
  it "should return an array" do
    create_pdf
    text_box = Prawn::Text::Box.new("", :document => @pdf)
    expect(text_box.valid_options).to be_a_kind_of(Array)
  end
end

describe "Text::Box#render" do
  it "should not fail if height is smaller than 1 line" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = {
      :height => @pdf.font.height * 0.5,
      :document => @pdf
    }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    expect(text_box.text).to eq("")
  end
  it "should draw content to the page" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.strings).not_to be_empty
  end
  it "should not draw a transformation matrix" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
    expect(matrices.matrices.length).to eq(0)
  end
end

describe "Text::Box#render(:single_line => true)" do
  it "should draw only one line to the page" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf,
                 :single_line => true }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.strings.length).to eq(1)
  end
end

describe "Text::Box#render(:dry_run => true)" do
  it "should not draw any content to the page" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render(:dry_run => true)
    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.strings).to be_empty
  end

  it "subsequent calls to render should_not raise_error an ArgumentError exception" do
    create_pdf
    @text = "™©"
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render(:dry_run => true)

    text_box.render
  end
end

describe "Text::Box#render(:valign => :bottom)" do
  it "#at should be the same from one dry run to the next" do
    create_pdf
    text = "this is center text " * 12
    options = { :width => 162,
                :valign => :bottom,
                :document => @pdf }
    text_box = Prawn::Text::Box.new(text, options)

    text_box.render(:dry_run => true)
    original_at = text_box.at.dup

    text_box.render(:dry_run => true)
    expect(text_box.at).to eq(original_at)
  end
end

describe "Text::Box#render(:valign => :center)" do
  it "#at should be the same from one dry run to the next" do
    create_pdf
    text = "this is center text " * 12
    options = { :width => 162,
                :valign => :center,
                :document => @pdf }
    text_box = Prawn::Text::Box.new(text, options)

    text_box.render(:dry_run => true)
    original_at = text_box.at.dup

    text_box.render(:dry_run => true)
    expect(text_box.at).to eq(original_at)
  end
end

describe "Text::Box#render with :rotate option of 30)" do
  before(:each) do
    create_pdf
    rotate = 30
    @x = 300
    @y = 70
    @width = 100
    @height = 50
    @cos = Math.cos(rotate * Math::PI / 180)
    @sin = Math.sin(rotate * Math::PI / 180)
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf,
                 :rotate => rotate,
                 :at => [@x, @y],
                 :width => @width,
                 :height => @height }
  end
  context ":rotate_around option of :center" do
    it "should draw content to the page rotated about the center of the text" do
      @options[:rotate_around] = :center
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x + @width / 2
      y = @y - @height / 2
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(x - x_prime),
                                          reduce_precision(y - y_prime)])
      expect(matrices.matrices[1]).to eq([reduce_precision(@cos),
                                          reduce_precision(@sin),
                                          reduce_precision(-@sin),
                                          reduce_precision(@cos), 0, 0])

      text = PDF::Inspector::Text.analyze(@pdf.render)
      expect(text.strings).not_to be_empty
    end
  end
  context ":rotate_around option of :upper_left" do
    it "should draw content to the page rotated about the upper left corner of the text" do
      @options[:rotate_around] = :upper_left
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x
      y = @y
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(x - x_prime),
                                          reduce_precision(y - y_prime)])
      expect(matrices.matrices[1]).to eq([reduce_precision(@cos),
                                          reduce_precision(@sin),
                                          reduce_precision(-@sin),
                                          reduce_precision(@cos), 0, 0])

      text = PDF::Inspector::Text.analyze(@pdf.render)
      expect(text.strings).not_to be_empty
    end
  end
  context "default :rotate_around" do
    it "should draw content to the page rotated about the upper left corner of the text" do
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x
      y = @y
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(x - x_prime),
                                          reduce_precision(y - y_prime)])
      expect(matrices.matrices[1]).to eq([reduce_precision(@cos),
                                          reduce_precision(@sin),
                                          reduce_precision(-@sin),
                                          reduce_precision(@cos), 0, 0])

      text = PDF::Inspector::Text.analyze(@pdf.render)
      expect(text.strings).not_to be_empty
    end
  end
  context ":rotate_around option of :upper_right" do
    it "should draw content to the page rotated about the upper right corner of the text" do
      @options[:rotate_around] = :upper_right
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x + @width
      y = @y
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(x - x_prime),
                                          reduce_precision(y - y_prime)])
      expect(matrices.matrices[1]).to eq([reduce_precision(@cos),
                                          reduce_precision(@sin),
                                          reduce_precision(-@sin),
                                          reduce_precision(@cos), 0, 0])

      text = PDF::Inspector::Text.analyze(@pdf.render)
      expect(text.strings).not_to be_empty
    end
  end
  context ":rotate_around option of :lower_right" do
    it "should draw content to the page rotated about the lower right corner of the text" do
      @options[:rotate_around] = :lower_right
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x + @width
      y = @y - @height
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(x - x_prime),
                                          reduce_precision(y - y_prime)])
      expect(matrices.matrices[1]).to eq([reduce_precision(@cos),
                                          reduce_precision(@sin),
                                          reduce_precision(-@sin),
                                          reduce_precision(@cos), 0, 0])

      text = PDF::Inspector::Text.analyze(@pdf.render)
      expect(text.strings).not_to be_empty
    end
  end
  context ":rotate_around option of :lower_left" do
    it "should draw content to the page rotated about the lower left corner of the text" do
      @options[:rotate_around] = :lower_left
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x
      y = @y - @height
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(x - x_prime),
                                          reduce_precision(y - y_prime)])
      expect(matrices.matrices[1]).to eq([reduce_precision(@cos),
                                          reduce_precision(@sin),
                                          reduce_precision(-@sin),
                                          reduce_precision(@cos), 0, 0])

      text = PDF::Inspector::Text.analyze(@pdf.render)
      expect(text.strings).not_to be_empty
    end
  end
end

describe "Text::Box default height" do
  before(:each) { create_pdf }

  it "should be the height from the bottom bound to document.y" do
    target_height = @pdf.y - @pdf.bounds.bottom
    @text = "Oh hai\n" * 60
    text_box = Prawn::Text::Box.new(@text, :document => @pdf)
    text_box.render
    expect(text_box.height).to be_within(@pdf.font.height).of(target_height)
  end

  it "should use the margin-box bottom if only in a stretchy bbox" do
    @pdf.bounding_box([0, @pdf.cursor], :width => @pdf.bounds.width) do
      target_height = @pdf.y - @pdf.bounds.bottom
      @text = "Oh hai\n" * 60
      text_box = Prawn::Text::Box.new(@text, :document => @pdf)
      text_box.render
      expect(text_box.height).to be_within(@pdf.font.height).of(target_height)
    end
  end

  it "should use the parent-box bottom if in a stretchy bbox and " \
    "overflow is :expand, even with an explicit height"do
    @pdf.bounding_box([0, @pdf.cursor], :width => @pdf.bounds.width) do
      target_height = @pdf.y - @pdf.bounds.bottom
      @text = "Oh hai\n" * 60
      text_box = Prawn::Text::Box.new(@text, :document => @pdf,
                                             :height => 100,
                                             :overflow => :expand)
      text_box.render
      expect(text_box.height).to be_within(@pdf.font.height).of(target_height)
    end
  end

  it "should use the innermost non-stretchy bbox, not the margin box" do
    @pdf.bounding_box([0, @pdf.cursor], :width => @pdf.bounds.width,
                                        :height => 200) do
      @pdf.bounding_box([0, @pdf.cursor], :width => @pdf.bounds.width) do
        @text = "Oh hai\n" * 60
        text_box = Prawn::Text::Box.new(@text, :document => @pdf)
        text_box.render
        expect(text_box.height).to be_within(@pdf.font.height).of(200)
      end
    end
  end
end

describe "Text::Box default at" do
  it "should be the left corner of the bounds, and the current document.y" do
    create_pdf
    target_at = [@pdf.bounds.left, @pdf.y]
    @text = "Oh hai text rect. " * 100
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    expect(text_box.at).to eq(target_at)
  end
end

describe "Text::Box with text than can fit in the box" do
  before(:each) do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = {
      :width => 162.0,
      :height => 162.0,
      :document => @pdf
    }
  end

  it "printed text should match requested text, except that preceding and " \
    "trailing white space will be stripped from each line, and newlines may " \
    "be inserted" do
    text_box = Prawn::Text::Box.new("  " + @text, @options)
    text_box.render
    expect(text_box.text.gsub("\n", " ")).to eq(@text.strip)
  end

  it "render should return an empty string because no text remains unprinted" do
    text_box = Prawn::Text::Box.new(@text, @options)
    expect(text_box.render).to eq("")
  end

  it "should be truncated when the leading is set high enough to prevent all the lines from being printed" do
    @options[:leading] = 40
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    expect(text_box.text.gsub("\n", " ")).not_to eq(@text.strip)
  end
end

describe "Text::Box with text that fits exactly in the box" do
  before(:each) do
    create_pdf
    @lines = 3
    @interlines = @lines - 1
    @text = (1..@lines).to_a.join("\n")
    @options = {
      :width => 162.0,
      :height => @pdf.font.ascender + @pdf.font.height * @interlines + @pdf.font.descender,
      :document => @pdf
    }
  end

  it "should have the expected height" do
    expected_height = @options.delete(:height)
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    expect(text_box.height).to be_within(0.0001).of(expected_height)
  end

  it "should print everything" do
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    expect(text_box.text).to eq(@text)
  end

  describe "with leading" do
    before(:each) do
      @options[:leading] = 15
    end

    it "should not overflow when enough height is added" do
      @options[:height] += @options[:leading] * @interlines
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render
      expect(text_box.text).to eq(@text)
    end

    it "should overflow when insufficient height is added" do
      @options[:height] += @options[:leading] * @interlines - 1
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render
      expect(text_box.text).not_to eq(@text)
    end
  end

  describe "with negative leading" do
    before(:each) do
      @options[:leading] = -4
    end

    it "should not overflow when enough height is removed" do
      @options[:height] += @options[:leading] * @interlines
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render
      expect(text_box.text).to eq(@text)
    end

    it "should overflow when too much height is removed" do
      @options[:height] += @options[:leading] * @interlines - 1
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render
      expect(text_box.text).not_to eq(@text)
    end
  end
end

describe "Text::Box printing UTF-8 string with higher bit characters" do
  before(:each) do
    create_pdf
    @text = "©"
    # not enough height to print any text, so we can directly compare against
    # the input string
    bounding_height = 1.0
    options = {
      :height => bounding_height,
      :document => @pdf
    }
    file = "#{Prawn::DATADIR}/fonts/Panic+Sans.dfont"
    @pdf.font_families["Panic Sans"] = {
      :normal      => { :file => file, :font => "PanicSans" },
      :italic      => { :file => file, :font => "PanicSans-Italic" },
      :bold        => { :file => file, :font => "PanicSans-Bold" },
      :bold_italic => { :file => file, :font => "PanicSans-BoldItalic" }
    }
    @text_box = Prawn::Text::Box.new(@text, options)
  end
  describe "when using a TTF font" do
    it "unprinted text should be in UTF-8 encoding" do
      @pdf.font("Panic Sans")
      remaining_text = @text_box.render
      expect(remaining_text).to eq(@text)
    end
  end

  describe "when using an AFM font" do
    it "unprinted text should be in UTF-8 encoding" do
      remaining_text = @text_box.render
      expect(remaining_text).to eq(@text)
    end
  end
end

describe "Text::Box with more text than can fit in the box" do
  before(:each) do
    create_pdf
    @text = "Oh hai text rect. " * 30
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
      @text_box = Prawn::Text::Box.new(@text, @options)
    end
    it "should be truncated" do
      @text_box.render
      expect(@text_box.text.gsub("\n", " ")).not_to eq(@text.strip)
    end
    it "render should not return an empty string because some text remains unprinted" do
      expect(@text_box.render).not_to be_empty
    end
    it "#height should be no taller than the specified height" do
      @text_box.render
      expect(@text_box.height).to be <= @bounding_height
    end
    it "#height should be within one font height of the specified height" do
      @text_box.render
      expect(@bounding_height).to be_within(@pdf.font.height).of(@text_box.height)
    end
    context "with :rotate option" do
      it "unrendered text should be the same as when not rotated" do
        remaining_text = @text_box.render

        rotate = 30
        x = 300
        y = 70
        width = @options[:width]
        height = @options[:height]
        @options[:document] = @pdf
        @options[:rotate] = rotate
        @options[:at] = [x, y]
        rotated_text_box = Prawn::Text::Box.new(@text, @options)
        expect(rotated_text_box.render).to eq(remaining_text)
      end
    end
  end

  context "truncated with text and size taken from the manual" do
    it "should return the right text" do
      @text = "This is the beginning of the text. It will be cut somewhere and " \
        "the rest of the text will procede to be rendered this time by " \
        "calling another method." + " . " * 50
      @options[:width] = 300
      @options[:height] = 50
      @options[:size] = 18
      @text_box = Prawn::Text::Box.new(@text, @options)
      remaining_text = @text_box.render
      expect(remaining_text).to eq("text will procede to be rendered this time by calling another method. .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . ")
    end
  end

  context "expand overflow" do
    before(:each) do
      @options[:overflow] = :expand
      @text_box = Prawn::Text::Box.new(@text, @options)
    end
    it "height should expand to encompass all the text (but not exceed the height of the page)" do
      @text_box.render
      expect(@text_box.height).to be > @bounding_height
    end
    it "should display the entire string (as long as there was space remaining on the page to print all the text)" do
      @text_box.render
      expect(@text_box.text.gsub("\n", " ")).to eq(@text.strip)
    end
    it "render should return an empty string because no text remains unprinted(as long as there was space remaining on the page to print all the text)" do
      expect(@text_box.render).to eq("")
    end
  end

  context "shrink_to_fit overflow" do
    before(:each) do
      @options[:overflow] = :shrink_to_fit
      @options[:min_font_size] = 2
      @text_box = Prawn::Text::Box.new(@text, @options)
    end
    it "should display the entire text" do
      @text_box.render
      expect(@text_box.text.gsub("\n", " ")).to eq(@text.strip)
    end
    it "render should return an empty string because no text remains unprinted" do
      expect(@text_box.render).to eq("")
    end
  end

  context "shrink_to_fit overflow" do
    it "should not drop below the minimum font size" do
      @options[:overflow] = :shrink_to_fit
      @options[:min_font_size] = 10.1
      @text_box = Prawn::Text::Box.new(@text, @options)
      @text_box.render

      text = PDF::Inspector::Text.analyze(@pdf.render)
      expect(text.font_settings[0][:size]).to eq(10.1)
    end
  end
end

describe "Text::Box with enough space to fit the text but using the " \
  "shrink_to_fit overflow" do
  it "should not shrink the text when there is no need to" do
    create_pdf
    @bounding_height = 162.0
    @options = {
      :width => 162.0,
      :height => @bounding_height,
      :overflow => :shrink_to_fit,
      :min_font_size => 5,
      :document => @pdf
    }
    @text_box = Prawn::Text::Box.new("hello\nworld", @options)
    @text_box.render

    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.font_settings[0][:size]).to eq(12)
  end
end

describe "Text::Box with a solid block of Chinese characters" do
  it "printed text should match requested text, except for newlines" do
    create_pdf
    @text = "写中国字" * 10
    @options = {
      :width => 162.0,
      :height => 162.0,
      :document => @pdf
    }
    @pdf.font "#{Prawn::DATADIR}/fonts/gkai00mp.ttf"
    @options[:overflow] = :truncate
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    expect(text_box.text.gsub("\n", "")).to eq(@text)
  end
end

describe "drawing bounding boxes" do
  before(:each) { create_pdf }

  it "should restore the margin box when bounding box exits" do
    margin_box = @pdf.bounds

    @pdf.text_box "Oh hai text box. " * 11, :height => @pdf.font.height * 10

    expect(@pdf.bounds).to eq(margin_box)
  end
end

describe "Text::Box#render with :character_spacing option" do
  it "should draw the character spacing to the document" do
    create_pdf
    string = "hello world"
    options = { :document => @pdf, :character_spacing => 10 }
    text_box = Prawn::Text::Box.new(string, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.character_spacing[0]).to eq(10)
  end
  it "should take character spacing into account when wrapping" do
    create_pdf
    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new("hello world",
                                    :width    => 100,
                                    :overflow => :expand,
                                    :character_spacing => 10,
                                    :document => @pdf)
    text_box.render
    expect(text_box.text).to eq("hello\nworld")
  end
end

describe "Text::Box wrapping" do
  before(:each) do
    create_pdf
  end

  it "should wrap text" do
    text = "Please wrap this text about HERE. More text that should be wrapped"
    expect = "Please wrap this text about\nHERE. More text that should be\nwrapped"

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                    :width    => 220,
                                    :overflow => :expand,
                                    :document => @pdf)
    text_box.render
    expect(text_box.text).to eq(expect)
  end

  # white space was being stripped after the entire line was generated, meaning
  # that leading white space characters reduced the amount of space on the line
  # for other characters, so wrapping "hello hello" resulted in
  # "hello\n\nhello", rather than "hello\nhello"
  #
  it "white space at beginning of line should not be taken into account when" \
    " computing line width" do
    text = "hello hello"
    expect = "hello\nhello"

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                    :width    => 40,
                                    :overflow => :expand,
                                    :document => @pdf)
    text_box.render
    expect(text_box.text).to eq(expect)
  end

  it "should respect end of line when wrapping text" do
    text = "Please wrap only before\nTHIS word. Don't wrap this"
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                    :width    => 220,
                                    :overflow => :expand,
                                    :document => @pdf)
    text_box.render
    expect(text_box.text).to eq(expect)
  end

  it "should respect multiple newlines when wrapping text" do
    text = "Please wrap only before THIS\n\nword. Don't wrap this"
    expect = "Please wrap only before\nTHIS\n\nword. Don't wrap this"

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                    :width    => 200,
                                    :overflow => :expand,
                                    :document => @pdf)
    text_box.render
    expect(text_box.text).to eq(expect)
  end

  it "should respect multiple newlines when wrapping text when those newlines coincide with a line break" do
    text = "Please wrap only before\n\nTHIS word. Don't wrap this"
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                    :width    => 220,
                                    :overflow => :expand,
                                    :document => @pdf)
    text_box.render
    expect(text_box.text).to eq(expect)
  end

  it "should respect initial newlines" do
    text = "\nThis should be on line 2"
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                    :width    => 220,
                                    :overflow => :expand,
                                    :document => @pdf)
    text_box.render
    expect(text_box.text).to eq(expect)
  end

  it "should wrap lines comprised of a single word of the bounds when wrapping text" do
    text = "You_can_wrap_this_text_HERE"
    expect = "You_can_wrap_this_text_HE\nRE"

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                    :width    => 180,
                                    :overflow => :expand,
                                    :document => @pdf)
    text_box.render
    expect(text_box.text).to eq(expect)
  end

  it "should wrap lines comprised of a single word of the bounds when wrapping text" do
    text = "©" * 30

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text, :width => 180,
                                          :overflow => :expand,
                                          :document => @pdf)

    text_box.render

    expected = "©" * 25 + "\n" + "©" * 5
    @pdf.font.normalize_encoding!(expected)
    expected = expected.force_encoding(Encoding::UTF_8)
    expect(text_box.text).to eq(expected)
  end

  it "should wrap non-unicode strings using single-byte word-wrapping" do
    text = "continúa esforzandote " * 5
    text_box = Prawn::Text::Box.new(text, :width => 180,
                                          :document => @pdf)
    text_box.render
    results_with_accent = text_box.text

    text = "continua esforzandote " * 5
    text_box = Prawn::Text::Box.new(text, :width => 180,
                                          :document => @pdf)
    text_box.render
    results_without_accent = text_box.text

    expect(first_line(results_with_accent).length).to eq(first_line(results_without_accent).length)
  end

  it "should allow you to disable wrapping by char" do
    text = "You_cannot_wrap_this_text_at_all_because_we_are_disabling_wrapping_by_char_and_there_are_no_word_breaks"

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                    :width => 180,
                                    :overflow => :shrink_to_fit,
                                    :disable_wrap_by_char => true,
                                    :document => @pdf)
    expect { text_box.render }.to raise_error(Prawn::Errors::CannotFit)
  end

  it "should retain full words with :shrink_to_fit if char wrapping is disabled" do
    text = "Wrapped_words"
    expect = "Wrapped_words"

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                    :width => 50,
                                    :height => 50,
                                    :size => 50,
                                    :overflow => :shrink_to_fit,
                                    :disable_wrap_by_char => true,
                                    :document => @pdf)
    text_box.render
    expect(text_box.text).to eq(expect)
  end
end

describe "Text::Box#render with :mode option" do
  it "should alter the text rendering mode of the document" do
    create_pdf
    string = "hello world"
    options = { :document => @pdf, :mode => :fill_stroke }
    text_box = Prawn::Text::Box.new(string, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.text_rendering_mode).to eq([2, 0])
  end
end

def reduce_precision(float)
  ("%.5f" % float).to_f
end

def first_line(str)
  str.each_line { |line| return line }
end
