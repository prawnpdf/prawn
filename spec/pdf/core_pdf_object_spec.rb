# encoding: ASCII-8BIT

# frozen_string_literal: true

require 'spec_helper'

# See PDF Reference, Sixth Edition (1.7) pp51-60 for details
RSpec.describe PDF::Core, '.pdf_object' do
  it "converts Ruby's nil to PDF null" do
    expect(described_class.pdf_object(nil)).to eq 'null'
  end

  it 'converts Ruby booleans to PDF booleans' do
    expect(described_class.pdf_object(true)).to eq 'true'
    expect(described_class.pdf_object(false)).to eq 'false'
  end

  describe 'numbers' do
    it 'converts a n integer to PDF number' do
      expect(described_class.pdf_object(42)).to eq '42'
    end

    it 'rounds a float to five significant digits' do
      expect(described_class.pdf_object(1.214117421)).to eq '1.21412'
    end

    it 'produces no trailing zeroes' do
      expect(described_class.pdf_object(1.200000001)).to eq '1.2'
    end
  end

  it 'drops trailing fraction zeros from numbers' do
    expect(described_class.pdf_object(42.0)).to eq '42'

    # numbers are rounded to four decimal places
    expect(described_class.pdf_object(1.200000)).to eq '1.2'
  end

  it 'converts a Ruby time object to a PDF timestamp' do
    t = Time.now
    expect(described_class.pdf_object(t))
      .to eq "#{t.strftime('(D:%Y%m%d%H%M%S%z').chop.chop}'00')"
  end

  it 'converts a Ruby string to PDF string when inside a content stream' do
    s = 'I can has a string'
    expect(PDF::Inspector.parse(described_class.pdf_object(s, true))).to eq s
  end

  it 'converts a Ruby string to a UTF-16 PDF string when outside of '\
    'a content stream' do
    s = 'I can has a string'
    s_utf16 = "\xFE\xFF#{s.unpack('U*').pack('n*')}"
    parsed_s = PDF::Inspector.parse(described_class.pdf_object(s, false))
    expect(parsed_s).to eq s_utf16
  end

  it 'converts a Ruby string with characters outside the BMP to its '\
     'UTF-16 representation with a BOM' do
    # U+10192 ROMAN SEMUNCIA SIGN
    semuncia = [65_938].pack('U')
    expect(described_class.pdf_object(semuncia, false).upcase)
      .to eq '<FEFFD800DD92>'
  end

  it 'passes through bytes regardless of content stream status for '\
    'ByteString' do
    expect(
      described_class.pdf_object(PDF::Core::ByteString.new("\xDE\xAD\xBE\xEF"))
        .upcase
    ).to eq '<DEADBEEF>'
  end

  it 'escapes parens when converting from Ruby string to PDF' do
    s = 'I )(can has a string'
    expect(PDF::Inspector.parse(described_class.pdf_object(s, true))).to eq s
  end

  it 'handles ruby escaped parens when converting to PDF string' do
    s = 'I can \\)( has string'
    expect(PDF::Inspector.parse(described_class.pdf_object(s, true))).to eq s
  end

  it 'escapes various strings correctly when converting a LiteralString' do
    ls = PDF::Core::LiteralString.new('abc')
    expect(described_class.pdf_object(ls)).to eq '(abc)'

    ls = PDF::Core::LiteralString.new("abc\x0Dde") # should escape \r
    expect(described_class.pdf_object(ls)).to eq "(abc\x5Crde)"

    ls = PDF::Core::LiteralString.new('abc(de') # should escape \(
    expect(described_class.pdf_object(ls)).to eq "(abc\x5C(de)"

    ls = PDF::Core::LiteralString.new('abc)de') # should escape \)
    expect(described_class.pdf_object(ls)).to eq "(abc\x5C)de)"

    ls = PDF::Core::LiteralString.new("abc\x5Cde") # should escape \\
    expect(described_class.pdf_object(ls)).to eq "(abc\x5C\x5Cde)"
    expect(described_class.pdf_object(ls).size).to eq 9
  end

  it 'escapes strings correctly when converting a LiteralString that is '\
    'not utf-8' do
    data = "\x43\xaf\xc9\x7f\xef\xf\xe6\xa8\xcb\x5c\xaf\xd0"
    ls = PDF::Core::LiteralString.new(data)
    expect(described_class.pdf_object(ls))
      .to eq "(\x43\xaf\xc9\x7f\xef\xf\xe6\xa8\xcb\x5c\x5c\xaf\xd0)"
  end

  it 'converts a Ruby symbol to PDF name' do
    expect(described_class.pdf_object(:my_symbol)).to eq '/my_symbol'
    expect(
      described_class.pdf_object(:"A;Name_With-Various***Characters?")
    ).to eq '/A;Name_With-Various***Characters?'
  end

  it 'converts a whitespace or delimiter containing Ruby symbol to '\
    'a PDF name' do
    expect(described_class.pdf_object(:'my symbol')).to eq '/my#20symbol'
    expect(described_class.pdf_object(:'my#symbol')).to eq '/my#23symbol'
    expect(described_class.pdf_object(:'my/symbol')).to eq '/my#2Fsymbol'
    expect(described_class.pdf_object(:'my(symbol')).to eq '/my#28symbol'
    expect(described_class.pdf_object(:'my)symbol')).to eq '/my#29symbol'
    expect(described_class.pdf_object(:'my<symbol')).to eq '/my#3Csymbol'
    expect(described_class.pdf_object(:'my>symbol')).to eq '/my#3Esymbol'
  end

  it 'converts a Ruby array to PDF Array when inside a content stream' do
    expect(described_class.pdf_object([1, 2, 3])).to eq '[1 2 3]'
    expect(
      PDF::Inspector.parse(
        described_class.pdf_object([[1, 2], :foo, 'Bar'], true)
      )
    ).to eq [[1, 2], :foo, 'Bar']
  end

  it 'converts a Ruby array to PDF Array when outside a content stream' do
    expect(described_class.pdf_object([1, 2, 3])).to eq '[1 2 3]'

    bar = "\xFE\xFF\x00B\x00a\x00r"
    expect(
      PDF::Inspector.parse(
        described_class.pdf_object([[1, 2], :foo, 'Bar'], false)
      )
    ).to eq [[1, 2], :foo, bar]
  end

  it 'converts a Ruby hash to a PDF Dictionary when inside a content stream' do
    dict = described_class.pdf_object(
      {
        :foo => :bar,
        'baz' => [1, 2, 3],
        :bang => { a: 'what', b: %i[you say] }
      },
      true
    )

    res = PDF::Inspector.parse(dict)

    expect(res[:foo]).to eq :bar
    expect(res[:baz]).to eq [1, 2, 3]
    expect(res[:bang]).to eq(a: 'what', b: %i[you say])
  end

  it 'converts a Ruby hash to a PDF Dictionary when outside a content stream' do
    what = "\xFE\xFF\x00w\x00h\x00a\x00t"
    dict = described_class.pdf_object(
      {
        foo: :bar,
        'baz' => [1, 2, 3],
        bang: { a: 'what', b: %i[you say] }
      },
      false
    )

    res = PDF::Inspector.parse(dict)

    expect(res[:foo]).to eq :bar
    expect(res[:baz]).to eq [1, 2, 3]
    expect(res[:bang]).to eq(a: what, b: %i[you say])
  end

  it 'does not allow keys other than strings or symbols for PDF dicts' do
    expect { described_class.pdf_object(:foo => :bar, :baz => :bang, 1 => 4) }
      .to raise_error(PDF::Core::Errors::FailedObjectConversion)
  end

  it 'converts a Prawn::Reference to a PDF indirect object reference' do
    ref = PDF::Core::Reference.new(1, true)
    expect(described_class.pdf_object(ref)).to eq ref.to_s
  end

  it 'converts a NameTree::Node to a PDF hash' do
    # FIXME: Soft dependency on Prawn::Document exists in Node
    node = PDF::Core::NameTree::Node.new(nil, 10)
    node.add 'hello', 1.0
    node.add 'world', 2.0
    data = described_class.pdf_object(node)
    res = PDF::Inspector.parse(data)
    expect(res).to eq(Names: ['hello', 1.0, 'world', 2.0])
  end
end
