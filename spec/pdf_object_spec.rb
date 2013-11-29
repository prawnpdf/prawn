# encoding: ASCII-8BIT

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

# See PDF Reference, Sixth Edition (1.7) pp51-60 for details
describe "PDF Object Serialization" do

  it "should convert Ruby's nil to PDF null" do
    PDF::PdfObject(nil).should == "null"
  end

  it "should convert Ruby booleans to PDF booleans" do
    PDF::PdfObject(true).should  == "true"
    PDF::PdfObject(false).should == "false"
  end

  it "should convert a Ruby number to PDF number" do
    PDF::PdfObject(1).should == "1"
    PDF::PdfObject(1.214112421).should == "1.214112421"
    # scientific notation is not valid in PDF
    PDF::PdfObject(0.000005).should == "0.000005"
  end

  it "should convert a Ruby time object to a PDF timestamp" do
    t = Time.now
    PDF::PdfObject(t).should == t.strftime("(D:%Y%m%d%H%M%S%z").chop.chop + "'00')"
  end

  it "should convert a Ruby string to PDF string when inside a content stream" do
    s = "I can has a string"
    PDF::Inspector.parse(PDF::PdfObject(s, true)).should == s
  end

  it "should convert a Ruby string to a UTF-16 PDF string when outside a content stream" do
    s = "I can has a string"
    s_utf16 = "\xFE\xFF" + s.unpack("U*").pack("n*")
    PDF::Inspector.parse(PDF::PdfObject(s, false)).should == s_utf16
  end

  it "should convert a Ruby string with characters outside the BMP to its " +
     "UTF-16 representation with a BOM" do
    # U+10192 ROMAN SEMUNCIA SIGN
    semuncia = [65938].pack("U")
    PDF::PdfObject(semuncia, false).upcase.should == "<FEFFD800DD92>"
  end

  it "should pass through bytes regardless of content stream status for ByteString" do
    PDF::PdfObject(PDF::ByteString.new("\xDE\xAD\xBE\xEF")).upcase.
      should == "<DEADBEEF>"
  end

  it "should escape parens when converting from Ruby string to PDF" do
    s =  'I )(can has a string'
    PDF::Inspector.parse(PDF::PdfObject(s, true)).should == s
  end

  it "should handle ruby escaped parens when converting to PDF string" do
    s = 'I can \\)( has string'
    PDF::Inspector.parse(PDF::PdfObject(s, true)).should == s
  end

  it "should escape various strings correctly when converting a LiteralString" do
    ls = PDF::LiteralString.new("abc")
    PDF::PdfObject(ls).should == "(abc)"

    ls = PDF::LiteralString.new("abc\x0Ade") # should escape \n
    PDF::PdfObject(ls).should == "(abc\x5C\x0Ade)"

    ls = PDF::LiteralString.new("abc\x0Dde") # should escape \r
    PDF::PdfObject(ls).should == "(abc\x5C\x0Dde)"

    ls = PDF::LiteralString.new("abc\x09de") # should escape \t
    PDF::PdfObject(ls).should == "(abc\x5C\x09de)"

    ls = PDF::LiteralString.new("abc\x08de") # should escape \b
    PDF::PdfObject(ls).should == "(abc\x5C\x08de)"

    ls = PDF::LiteralString.new("abc\x0Cde") # should escape \f
    PDF::PdfObject(ls).should == "(abc\x5C\x0Cde)"

    ls = PDF::LiteralString.new("abc(de") # should escape \(
    PDF::PdfObject(ls).should == "(abc\x5C(de)"

    ls = PDF::LiteralString.new("abc)de") # should escape \)
    PDF::PdfObject(ls).should == "(abc\x5C)de)"

    ls = PDF::LiteralString.new("abc\x5Cde") # should escape \\
    PDF::PdfObject(ls).should == "(abc\x5C\x5Cde)"
    PDF::PdfObject(ls).size.should == 9
  end

  it "should escape strings correctly when converting a LiteralString that is not utf-8" do
    data = "\x43\xaf\xc9\x7f\xef\xf\xe6\xa8\xcb\x5c\xaf\xd0"
    ls = PDF::LiteralString.new(data)
    PDF::PdfObject(ls).should == "(\x43\xaf\xc9\x7f\xef\xf\xe6\xa8\xcb\x5c\x5c\xaf\xd0)"
  end

  it "should convert a Ruby symbol to PDF name" do
    PDF::PdfObject(:my_symbol).should == "/my_symbol"
    PDF::PdfObject(:"A;Name_With-Various***Characters?").should ==
     "/A;Name_With-Various***Characters?"
  end

  it "should convert a whitespace or delimiter containing Ruby symbol to a PDF name" do
    PDF::PdfObject(:"my symbol").should == "/my#20symbol"
    PDF::PdfObject(:"my#symbol").should == "/my#23symbol"
    PDF::PdfObject(:"my/symbol").should == "/my#2Fsymbol"
    PDF::PdfObject(:"my(symbol").should == "/my#28symbol"
    PDF::PdfObject(:"my)symbol").should == "/my#29symbol"
    PDF::PdfObject(:"my<symbol").should == "/my#3Csymbol"
    PDF::PdfObject(:"my>symbol").should == "/my#3Esymbol"
  end

  it "should convert a Ruby array to PDF Array when inside a content stream" do
    PDF::PdfObject([1,2,3]).should == "[1 2 3]"
    PDF::Inspector.parse(PDF::PdfObject([[1,2],:foo,"Bar"], true)).should ==
      [[1,2],:foo, "Bar"]
  end

  it "should convert a Ruby array to PDF Array when outside a content stream" do
    bar = "\xFE\xFF" + "Bar".unpack("U*").pack("n*")
    PDF::PdfObject([1,2,3]).should == "[1 2 3]"
    PDF::Inspector.parse(PDF::PdfObject([[1,2],:foo,"Bar"], false)).should ==
      [[1,2],:foo, bar]
  end

  it "should convert a Ruby hash to a PDF Dictionary when inside a content stream" do
    dict = PDF::PdfObject( {:foo  => :bar,
                              "baz" => [1,2,3],
                              :bang => {:a => "what", :b => [:you, :say] }}, true )

    res = PDF::Inspector.parse(dict)

    res[:foo].should == :bar
    res[:baz].should == [1,2,3]
    res[:bang].should == { :a => "what", :b => [:you, :say] }

  end

  it "should convert a Ruby hash to a PDF Dictionary when outside a content stream" do
    what = "\xFE\xFF" + "what".unpack("U*").pack("n*")
    dict = PDF::PdfObject( {:foo  => :bar,
                              "baz" => [1,2,3],
                              :bang => {:a => "what", :b => [:you, :say] }}, false )

    res = PDF::Inspector.parse(dict)

    res[:foo].should == :bar
    res[:baz].should == [1,2,3]
    res[:bang].should == { :a => what, :b => [:you, :say] }

  end

  it "should not allow keys other than strings or symbols for PDF dicts" do
    lambda { PDF::PdfObject(:foo => :bar, :baz => :bang, 1 => 4) }.
      should raise_error(Prawn::Errors::FailedObjectConversion)
  end

  it "should convert a Prawn::Reference to a PDF indirect object reference" do
    ref = PDF::Reference(1,true)
    PDF::PdfObject(ref).should == ref.to_s
  end

  it "should convert a NameTree::Node to a PDF hash" do
    node = PDF::NameTree::Node.new(Prawn::Document.new, 10)
    node.add "hello", 1.0
    node.add "world", 2.0
    data = PDF::PdfObject(node)
    res = PDF::Inspector.parse(data)
    res.should == {:Names => ["hello", 1.0, "world", 2.0]}
  end
end
