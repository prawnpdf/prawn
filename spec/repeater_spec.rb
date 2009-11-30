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

  def sample_document
    doc = Prawn::Document.new(:skip_page_creation => true)
    10.times { |e| doc.start_new_page }
    
    doc
  end

  def repeater(*args, &b)
    Prawn::Repeater.new(*args,&b)
  end

end
