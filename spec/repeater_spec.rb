require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")           

describe "Repeaters" do

  it "creates a stamp and increments Prawn::Repeater.count on initialize" do
    orig_count = Prawn::Repeater.count

    doc = sample_document
    doc.expects(:create_stamp).with("prawn_repeater(#{orig_count})")

    r = repeater(doc, :all) { :do_nothing }

    assert_equal orig_count + 1,  Prawn::Repeater.count 
  end

  it "must provide an :all filter" do
    doc = sample_document
    r = repeater(doc, :all) { :do_nothing }
   
    assert (1..doc.page_count).all? { |i| r.match?(i) }
  end

  it "must provide an :odd filter" do
    doc = sample_document
    r = repeater(doc, :odd) { :do_nothing }

    odd, even = (1..doc.page_count).partition { |e| e % 2 == 1 }

    assert odd.all? { |i| r.match?(i) }
    assert ! even.any? { |i| r.match?(i) }
  end

  it "must be able to filter by an array of page numbers" do
    doc = sample_document
    r = repeater(doc, [1,2,7]) { :do_nothing }

    assert_equal [1,2,7], (1..10).select { |i| r.match?(i) }
  end

  it "must be able to filter by a range of page numbers" do
    doc = sample_document
    r = repeater(doc, 2..4) { :do_nothing }

    assert_equal [2,3,4], (1..10).select { |i| r.match?(i) }
  end

  it "must be able to filter by an arbitrary proc" do
    doc = sample_document
    r = repeater(doc, lambda { |x| x == 1 or x % 3 == 0 })

    assert_equal [1,3,6,9], (1..10).select { |i| r.match?(i) }
  end

  it "must try to run a stamp if the page number matches" do
    doc = sample_document
    doc.expects(:stamp)

    repeater(doc, :odd).run(3)
  end

  it "must not try to run a stamp if the page number matches" do
    doc = sample_document

    doc.expects(:stamp).never
    repeater(doc, :odd).run(2)
  end
  
  it "must not try to run a stamp if dynamic is selected" do
    doc = sample_document

    doc.expects(:stamp).never
    (1..10).each { |p| repeater(doc, :all, true){:do_nothing}.run(p) }
  end
  
  it "must render the block in context of page when dynamic is selected" do
    doc = sample_document

    doc.repeat(:all, :dynamic => true) do 
      draw_text page_number, :at => [500, 0]
    end

    text = PDF::Inspector::Text.analyze(doc.render)  
    assert_equal (1..10).to_a.map{|p| p.to_s}, text.strings 
  end

  def sample_document
    doc = Prawn::Document.new(:skip_page_creation => true)
    10.times { |e| doc.start_new_page }
    doc
  end

  def repeater(*args, &b)
    Prawn::Repeater.new(*args,&b)
  end

end
