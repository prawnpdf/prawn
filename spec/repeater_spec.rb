# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Repeaters" do

  it "creates a stamp and increments Prawn::Repeater.count on initialize" do
    orig_count = Prawn::Repeater.count

    doc = sample_document
    doc.expects(:create_stamp).with("prawn_repeater(#{orig_count})")

    r = repeater(doc, :all) { :do_nothing }

    Prawn::Repeater.count.should == orig_count + 1
  end

  it "must provide an :all filter" do
    doc = sample_document
    r = repeater(doc, :all) { :do_nothing }

    (1..doc.page_count).all? { |i| r.match?(i) }.should be_true
  end

  it "must provide an :odd filter" do
    doc = sample_document
    r = repeater(doc, :odd) { :do_nothing }

    odd, even = (1..doc.page_count).partition { |e| e % 2 == 1 }

    odd.all? { |i| r.match?(i) }.should be_true
    even.any? { |i| r.match?(i) }.should be_false
  end

  it "must be able to filter by an array of page numbers" do
    doc = sample_document
    r = repeater(doc, [1,2,7]) { :do_nothing }

    (1..10).select { |i| r.match?(i) }.should == [1,2,7]
  end

  it "must be able to filter by a range of page numbers" do
    doc = sample_document
    r = repeater(doc, 2..4) { :do_nothing }

    (1..10).select { |i| r.match?(i) }.should == [2,3,4]
  end

  it "must be able to filter by an arbitrary proc" do
    doc = sample_document
    r = repeater(doc, lambda { |x| x == 1 or x % 3 == 0 })

    (1..10).select { |i| r.match?(i) }.should == [1,3,6,9]
  end

  it "must try to run a stamp if the page number matches" do
    doc = sample_document
    doc.expects(:stamp)

    repeater(doc, :odd).run(3)
  end

  it "must not try to run a stamp unless the page number matches" do
    doc = sample_document

    doc.expects(:stamp).never
    repeater(doc, :odd).run(2)
  end

  it "must not try to run a stamp if dynamic is selected" do
    doc = sample_document

    doc.expects(:stamp).never
    (1..10).each { |p| repeater(doc, :all, true){:do_nothing}.run(p) }
  end

  it "must try to run a block if the page number matches" do
    doc = sample_document

    doc.expects(:draw_text).twice
    (1..10).each { |p| repeater(doc, [1,2], true){doc.draw_text "foo"}.run(p) }
  end

  it "must not try to run a block unless the page number matches" do
    doc = sample_document

    doc.expects(:draw_text).never
    repeater(doc, :odd, true){doc.draw_text "foo"}.run(2)
  end

  it "must treat any block as a closure" do
    doc = sample_document

    @page = "Page" # ensure access to ivars
    doc.repeat(:all, :dynamic => true) do
      doc.draw_text "#@page #{doc.page_number}", :at => [500, 0]
    end

    text = PDF::Inspector::Text.analyze(doc.render)
    text.strings.should == (1..10).to_a.map{|p| "Page #{p}"}
  end

  it "must treat any block as a closure (Document.new instance_eval form)" do
    doc = Prawn::Document.new(:skip_page_creation => true) do
      10.times { start_new_page }

      @page = "Page"
      repeat(:all, :dynamic => true) do
        # ensure self is accessible here
        draw_text "#@page #{page_number}", :at => [500, 0]
      end
    end

    text = PDF::Inspector::Text.analyze(doc.render)
    text.strings.should == (1..10).to_a.map{|p| "Page #{p}"}
  end

  def sample_document
    doc = Prawn::Document.new(:skip_page_creation => true)
    10.times { |e| doc.start_new_page }
    doc
  end

  def repeater(*args, &b)
    Prawn::Repeater.new(*args,&b)
  end

  context "graphic state" do

    it "should not alter the graphic state stack color space" do
      create_pdf
      starting_color_space = @pdf.state.page.graphic_state.color_space.dup
      @pdf.repeat :all do
        @pdf.text "Testing", :size => 24, :style => :bold
      end
      @pdf.state.page.graphic_state.color_space.should == starting_color_space
    end

    context "dynamic repeaters" do

      it "should preserve the graphic state at creation time" do
        create_pdf
        @pdf.repeat :all, :dynamic => true do
          @pdf.text "fill_color: #{@pdf.graphic_state.fill_color}"
          @pdf.text "cap_style: #{@pdf.graphic_state.cap_style}"
        end
        @pdf.fill_color "666666"
        @pdf.cap_style :round
        text = PDF::Inspector::Text.analyze(@pdf.render)
        text.strings.include?("fill_color: 666666").should == false
        text.strings.include?("fill_color: 000000").should == true
        text.strings.include?("cap_style: round").should == false
        text.strings.include?("cap_style: butt").should == true
      end

    end

  end

end
