# encoding: utf-8
require "tempfile"

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Document encryption" do
  describe "Password padding" do
    include Prawn::Document::Security

    it "should truncate long passwords" do
      pw = "Long long string" * 30
      padded = pad_password(pw)
      expect(padded.length).to eq(32)
      expect(padded).to eq(pw[0, 32])
    end

    it "should pad short passwords" do
      pw = "abcd"
      padded = pad_password(pw)
      expect(padded.length).to eq(32)
      expect(padded).to eq(pw + Prawn::Document::Security::PasswordPadding[0, 28])
    end

    it "should fully pad null passwords" do
      pw = ""
      padded = pad_password(pw)
      expect(padded.length).to eq(32)
      expect(padded).to eq(Prawn::Document::Security::PasswordPadding)
    end
  end

  describe "Setting permissions" do
    def doc_with_permissions(permissions)
      pdf = Prawn::Document.new

      class << pdf
        # Make things easier to test
        public :permissions_value
      end

      pdf.encrypt_document(:permissions => permissions)
      pdf
    end

    it "should default to full permissions" do
      expect(doc_with_permissions({}).permissions_value).to eq(0xFFFFFFFF)
      expect(doc_with_permissions(:print_document     => true,
                                  :modify_contents    => true,
                                  :copy_contents      => true,
                                  :modify_annotations => true).permissions_value).
        to eq(0xFFFFFFFF)
    end

    it "should clear the appropriate bits for each permission flag" do
      expect(doc_with_permissions(:print_document => false).permissions_value).
        to eq(0b1111_1111_1111_1111_1111_1111_1111_1011)
      expect(doc_with_permissions(:modify_contents => false).permissions_value).
        to eq(0b1111_1111_1111_1111_1111_1111_1111_0111)
      expect(doc_with_permissions(:copy_contents => false).permissions_value).
        to eq(0b1111_1111_1111_1111_1111_1111_1110_1111)
      expect(doc_with_permissions(:modify_annotations => false).permissions_value).
        to eq(0b1111_1111_1111_1111_1111_1111_1101_1111)
    end

    it "should raise_error ArgumentError if invalid option is provided" do
      expect {
        doc_with_permissions(:modify_document => false)
      }.to raise_error(ArgumentError)
    end
  end

  describe "Encryption keys" do
    # Since PDF::Reader doesn't read encrypted PDF files, we just take the
    # roundabout method of verifying each step of the encryption. This works
    # fine because the encryption method is deterministic.

    before(:each) do
      @pdf = Prawn::Document.new
      class << @pdf
        public :owner_password_hash, :user_password_hash, :user_encryption_key
      end
      @pdf.encrypt_document :user_password => 'foo',
                            :owner_password => 'bar',
                            :permissions => { :print_document => false }
    end

    it "should calculate the correct owner hash" do
      expect(@pdf.owner_password_hash.unpack("H*").first).to match(/^61CA855012/i)
    end

    it "should calculate the correct user hash" do
      expect(@pdf.user_password_hash.unpack("H*").first).to match(/^6BC8C51031/i)
    end

    it "should calculate the correct user_encryption_key" do
      expect(@pdf.user_encryption_key.unpack("H*").first.upcase).to eq("B100AB6429")
    end
  end

  describe "EncryptedPdfObject" do
    it "should delegate to PdfObject for simple types" do
      expect(PDF::Core::EncryptedPdfObject(true, nil, nil, nil)).to eq("true")
      expect(PDF::Core::EncryptedPdfObject(42, nil, nil, nil)).to eq("42")
    end

    it "should encrypt strings properly" do
      expect(PDF::Core::EncryptedPdfObject("foo", "12345", 123, 0)).to eq("<4ad6e3>")
    end

    it "should encrypt literal strings properly" do
      expect(PDF::Core::EncryptedPdfObject(PDF::Core::LiteralString.new("foo"), "12345", 123, 0)).to eq(bin_string("(J\xD6\xE3)"))
      expect(PDF::Core::EncryptedPdfObject(PDF::Core::LiteralString.new("lhfbqg3do5u0satu3fjf"), nil, 123, 0)).to eq(bin_string("(\xF1\x8B\\(\b\xBB\xE18S\x130~4*#\\(%\x87\xE7\x8E\\\n)"))
    end

    it "should encrypt time properly" do
      expect(PDF::Core::EncryptedPdfObject(Time.utc(2050, 04, 26, 10, 17, 10), "12345", 123, 0)).to eq(bin_string("(h\x83\xBE\xDC\xEC\x99\x0F\xD7\\)%\x13\xD4$\xB8\xF0\x16\xB8\x80\xC5\xE91+\xCF)"))
    end

    it "should properly handle compound types" do
      expect(PDF::Core::EncryptedPdfObject({ :Bar => "foo" }, "12345", 123, 0)).to eq(
        "<< /Bar <4ad6e3>\n>>"
      )
      expect(PDF::Core::EncryptedPdfObject(["foo", "bar"], "12345", 123, 0)).to eq(
        "[<4ad6e3> <4ed8fe>]"
      )
    end
  end

  describe "Reference#encrypted_object" do
    it "should encrypt references properly" do
      ref = PDF::Core::Reference(1,["foo"])
      expect(ref.encrypted_object(nil)).to eq("1 0 obj\n[<4fca3f>]\nendobj\n")
    end

    it "should encrypt references with streams properly" do
      ref = PDF::Core::Reference(1, {})
      ref << 'foo'
      result = bin_string("1 0 obj\n<< /Length 3\n>>\nstream\nO\xCA?\nendstream\nendobj\n")
      expect(ref.encrypted_object(nil)).to eq(result)
    end
  end

  describe "String#encrypted_object" do
    it "should encrypt stream properly" do
      stream = PDF::Core::Stream.new
      stream << "foo"
      result = bin_string("stream\nO\xCA?\nendstream\n")
      expect(stream.encrypted_object(nil, 1, 0)).to eq(result)
    end
  end
end
