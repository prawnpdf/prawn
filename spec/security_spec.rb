# encoding: utf-8
require "tempfile"

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

describe "Document encryption" do

  describe "Password padding" do

    include Prawn::Document::Security

    it "should truncate long passwords" do
      pw = "Long long string" * 30
      padded = pad_password(pw)
      padded.length.should == 32
      padded.should == pw[0, 32]
    end

    it "should pad short passwords" do
      pw = "abcd"
      padded = pad_password(pw)
      padded.length.should == 32
      padded.should == pw + Prawn::Document::Security::PasswordPadding[0, 28]
    end

    it "should fully pad null passwords" do
      pw = ""
      padded = pad_password(pw)
      padded.length.should == 32
      padded.should == Prawn::Document::Security::PasswordPadding
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
      doc_with_permissions({}).permissions_value.should == 0xFFFFFFFF
      doc_with_permissions(:print_document     => true,
                           :modify_contents    => true,
                           :copy_contents      => true,
                           :modify_annotations => true).permissions_value.
        should == 0xFFFFFFFF
    end

    it "should clear the appropriate bits for each permission flag" do
      doc_with_permissions(:print_document => false).permissions_value.
        should == 0b1111_1111_1111_1111_1111_1111_1111_1011
      doc_with_permissions(:modify_contents => false).permissions_value.
        should == 0b1111_1111_1111_1111_1111_1111_1111_0111
      doc_with_permissions(:copy_contents => false).permissions_value.
        should == 0b1111_1111_1111_1111_1111_1111_1110_1111
      doc_with_permissions(:modify_annotations => false).permissions_value.
        should == 0b1111_1111_1111_1111_1111_1111_1101_1111
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
      @pdf.encrypt_document :user_password => 'foo', :owner_password => 'bar',
        :permissions => { :print_document => false }
    end

    it "should calculate the correct owner hash" do
      @pdf.owner_password_hash.unpack("H*").first.should.match(/^61CA855012/i)
    end

    it "should calculate the correct user hash" do
      @pdf.user_password_hash.unpack("H*").first.should =~ /^6BC8C51031/i
    end

    it "should calculate the correct user_encryption_key" do
      @pdf.user_encryption_key.unpack("H*").first.upcase.should == "B100AB6429"
    end


  end

  describe "EncryptedPdfObject" do

    it "should delegate to PdfObject for simple types" do
      Prawn::Core::EncryptedPdfObject(true, nil, nil, nil).should == "true"
      Prawn::Core::EncryptedPdfObject(42, nil, nil, nil).should == "42"
    end

    it "should encrypt strings properly" do
      Prawn::Core::EncryptedPdfObject("foo", "12345", 123, 0).should == "<4ad6e3>"
    end

    it "should properly handle compound types" do
      Prawn::Core::EncryptedPdfObject({:Bar => "foo"}, "12345", 123, 0).should ==
        "<< /Bar <4ad6e3>\n>>"
      Prawn::Core::EncryptedPdfObject(["foo", "bar"], "12345", 123, 0).should ==
        "[<4ad6e3> <4ed8fe>]"
    end
    
  end

end
