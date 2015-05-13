# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Formatted::Fragment#space_count" do
  it "should return the number of spaces in the fragment" do
    create_pdf
    format_state = {}
    fragment = Prawn::Text::Formatted::Fragment.new("hello world ",
                                                    format_state,
                                                    @pdf)
    expect(fragment.space_count).to eq(2)
  end
  it "should exclude trailing spaces from the count when " \
    ":exclude_trailing_white_space => true" do
    create_pdf
    format_state = { :exclude_trailing_white_space => true }
    fragment = Prawn::Text::Formatted::Fragment.new("hello world ",
                                                    format_state,
                                                    @pdf)
    expect(fragment.space_count).to eq(1)
  end
end

describe "Text::Formatted::Fragment#include_trailing_white_space!" do
  it "should make the fragment include trailing white space" do
    create_pdf
    format_state = { :exclude_trailing_white_space => true }
    fragment = Prawn::Text::Formatted::Fragment.new("hello world ",
                                                    format_state,
                                                    @pdf)
    expect(fragment.space_count).to eq(1)
    fragment.include_trailing_white_space!
    expect(fragment.space_count).to eq(2)
  end
end

describe "Text::Formatted::Fragment#text" do
  it "should return the fragment text" do
    create_pdf
    format_state = {}
    fragment = Prawn::Text::Formatted::Fragment.new("hello world ",
                                                    format_state,
                                                    @pdf)
    expect(fragment.text).to eq("hello world ")
  end
  it "should return the fragment text without trailing spaces when " \
    ":exclude_trailing_white_space => true" do
    create_pdf
    format_state = { :exclude_trailing_white_space => true }
    fragment = Prawn::Text::Formatted::Fragment.new("hello world ",
                                                    format_state,
                                                    @pdf)
    expect(fragment.text).to eq("hello world")
  end
end

describe "Text::Formatted::Fragment#word_spacing=" do
  before(:each) do
    create_pdf
    format_state = { :styles => [:bold, :italic],
                     :color => nil,
                     :link => nil,
                     :anchor => nil,
                     :font => nil,
                     :size => nil }
    @fragment = Prawn::Text::Formatted::Fragment.new("hello world",
                                                     format_state,
                                                     @pdf)
    @fragment.width = 100
    @fragment.left = 50
    @fragment.baseline = 200
    @fragment.line_height = 27
    @fragment.descender = 7
    @fragment.ascender = 17
    @fragment.word_spacing = 10
  end

  it "should account for word_spacing in #width" do
    expect(@fragment.width).to eq(110)
  end
  it "should account for word_spacing in #bounding_box" do
    target_box = [50, 193, 160, 217]
    expect(@fragment.bounding_box).to eq(target_box)
  end
  it "should account for word_spacing in #absolute_bounding_box" do
    target_box = [50, 193, 160, 217]
    target_box[0] += @pdf.bounds.absolute_left
    target_box[1] += @pdf.bounds.absolute_bottom
    target_box[2] += @pdf.bounds.absolute_left
    target_box[3] += @pdf.bounds.absolute_bottom
    expect(@fragment.absolute_bounding_box).to eq(target_box)
  end
  it "should account for word_spacing in #underline_points" do
    y = 198.75
    target_points = [[50, y], [160, y]]
    expect(@fragment.underline_points).to eq(target_points)
  end
  it "should account for word_spacing in #strikethrough_points" do
    y = 200 + @fragment.ascender * 0.3
    target_points = [[50, y], [160, y]]
    expect(@fragment.strikethrough_points).to eq(target_points)
  end
end

describe "Text::Formatted::Fragment" do
  before(:each) do
    create_pdf
    format_state = { :styles => [:bold, :italic],
                     :color => nil,
                     :link => nil,
                     :anchor => nil,
                     :font => nil,
                     :size => nil }
    @fragment = Prawn::Text::Formatted::Fragment.new("hello world",
                                                     format_state,
                                                     @pdf)
    @fragment.width = 100
    @fragment.left = 50
    @fragment.baseline = 200
    @fragment.line_height = 27
    @fragment.descender = 7
    @fragment.ascender = 17
  end

  describe "#width" do
    it "should return the width" do
      expect(@fragment.width).to eq(100)
    end
  end

  describe "#styles" do
    it "should return the styles array" do
      expect(@fragment.styles).to eq([:bold, :italic])
    end
    it "should never return nil" do
      format_state = { :styles => nil,
                       :color => nil,
                       :link => nil,
                       :anchor => nil,
                       :font => nil,
                       :size => nil }
      fragment = Prawn::Text::Formatted::Fragment.new("hello world",
                                                      format_state,
                                                      @pdf)
      expect(fragment.styles).to eq([])
    end
  end

  describe "#line_height" do
    it "should return the line_height" do
      expect(@fragment.line_height).to eq(27)
    end
  end

  describe "#ascender" do
    it "should return the ascender" do
      expect(@fragment.ascender).to eq(17)
    end
  end

  describe "#descender" do
    it "should return the descender" do
      expect(@fragment.descender).to eq(7)
    end
  end

  describe "#y_offset" do
    it "should be zero" do
      expect(@fragment.y_offset).to eq(0)
    end
  end

  describe "#bounding_box" do
    it "should return the bounding box surrounding the fragment" do
      target_box = [50, 193, 150, 217]
      expect(@fragment.bounding_box).to eq(target_box)
    end
  end

  describe "#absolute_bounding_box" do
    it "should return the bounding box surrounding the fragment" \
       " in absolute coordinates" do
      target_box = [50, 193, 150, 217]
      target_box[0] += @pdf.bounds.absolute_left
      target_box[1] += @pdf.bounds.absolute_bottom
      target_box[2] += @pdf.bounds.absolute_left
      target_box[3] += @pdf.bounds.absolute_bottom

      expect(@fragment.absolute_bounding_box).to eq(target_box)
    end
  end

  describe "#underline_points" do
    it "should define a line under the fragment" do
      y = 198.75
      target_points = [[50, y], [150, y]]
      expect(@fragment.underline_points).to eq(target_points)
    end
  end

  describe "#strikethrough_points" do
    it "should define a line through the fragment" do
      y = 200 + @fragment.ascender * 0.3
      target_points = [[50, y], [150, y]]
      expect(@fragment.strikethrough_points).to eq(target_points)
    end
  end
end

describe "Text::Formatted::Fragment that is a subscript" do
  before(:each) do
    create_pdf
    format_state = { :styles => [:subscript],
                     :color => nil,
                     :link => nil,
                     :anchor => nil,
                     :font => nil,
                     :size => nil }
    @fragment = Prawn::Text::Formatted::Fragment.new("hello world",
                                                     format_state,
                                                     @pdf)
    @fragment.line_height = 27
    @fragment.descender = 7
    @fragment.ascender = 17
  end
  describe "#subscript?" do
    it "should be_true" do
      expect(@fragment).to be_subscript
    end
  end
  describe "#y_offset" do
    it "should return a negative value" do
      expect(@fragment.y_offset).to be < 0
    end
  end
end

describe "Text::Formatted::Fragment that is a superscript" do
  before(:each) do
    create_pdf
    format_state = { :styles => [:superscript],
                     :color => nil,
                     :link => nil,
                     :anchor => nil,
                     :font => nil,
                     :size => nil }
    @fragment = Prawn::Text::Formatted::Fragment.new("hello world",
                                                     format_state,
                                                     @pdf)
    @fragment.line_height = 27
    @fragment.descender = 7
    @fragment.ascender = 17
  end
  describe "#superscript?" do
    it "should be_true" do
      expect(@fragment).to be_superscript
    end
  end
  describe "#y_offset" do
    it "should return a positive value" do
      expect(@fragment.y_offset).to be > 0
    end
  end
end

describe "Text::Formatted::Fragment with :direction => :rtl" do
  it "#text should be reversed" do
    create_pdf
    format_state = { :direction => :rtl }
    fragment = Prawn::Text::Formatted::Fragment.new("hello world",
                                                    format_state,
                                                    @pdf)
    expect(fragment.text).to eq("dlrow olleh")
  end
end

describe "Text::Formatted::Fragment default_direction=" do
  it "should set the direction if there is no fragment level direction " \
     "specification" do
    create_pdf
    format_state = {}
    fragment = Prawn::Text::Formatted::Fragment.new("hello world",
                                                    format_state,
                                                    @pdf)
    fragment.default_direction = :rtl
    expect(fragment.direction).to eq(:rtl)
  end
  it "should not set the direction if there is a fragment level direction " \
     "specification" do
    create_pdf
    format_state = { :direction => :rtl }
    fragment = Prawn::Text::Formatted::Fragment.new("hello world",
                                                    format_state,
                                                    @pdf)
    fragment.default_direction = :ltr
    expect(fragment.direction).to eq(:rtl)
  end
end
