# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Prawn::Document#transaction" do

  it "should properly commit if no error is raised" do
    pdf = Prawn::Document.new do
      transaction do
        text "This is shown"
      end
    end
    text = PDF::Inspector::Text.analyze(pdf.render)
    text.strings.should == ["This is shown"]
  end

  it "should not display text if transaction is rolled back" do
    pdf = Prawn::Document.new do
      transaction do
        text "This is not shown"
        rollback
      end
    end
    text = PDF::Inspector::Text.analyze(pdf.render)
    text.strings.should == []
  end 

  it "should return true/false value indicating success of the transaction" do
    Prawn::Document.new do
      success = transaction { }
      success.should == true

      success = transaction { rollback }
      success.should == false
    end
  end
  
  it "should support nested transactions" do
    pdf = Prawn::Document.new do
      transaction do
        text "This is shown"
        transaction do
          text "and this is not"
          rollback
        end
        text "and this is"
      end
    end
    text = PDF::Inspector::Text.analyze(pdf.render)
    text.strings.should == ["This is shown", "and this is"]
  end

  it "should allow rollback of multiple pages" do
    pdf = Prawn::Document.new do
      transaction do
        5.times { start_new_page }
        text "way out there and will never be shown"
        rollback
      end
      text "This is the real text, only one page"
    end

    pages = PDF::Inspector::Page.analyze(pdf.render).pages
    pages.size.should == 1
  end

  # Because the Pages object, when restored, points to the snapshotted pages
  # by identifier, we have to restore the snapshot into the same page objects,
  # or else old pages will appear in the post-rollback document.
  it "should restore the pages into the same objects" do
    Prawn::Document.new do
      old_page_object_id = state.page.dictionary.identifier
      old_page_content_id = state.page.content.identifier

      transaction do
        start_new_page
        rollback
      end

      state.page.dictionary.identifier.should == old_page_object_id
      state.page.content.identifier.should == old_page_content_id
    end

  end

  it "page object should refer to the page_content object after restore" do

    Prawn::Document.new do
      transaction do
        start_new_page
        rollback
      end

      # should be the exact same object, not a clone
      state.page.dictionary.data[:Contents].should == state.page.content
    end

  end
  
  describe "with a stamp dictionary present" do

    it "should properly commit if no error is raised" do
      pdf = Prawn::Document.new do
        create_stamp("test_stamp") { draw_text "This is shown", :at => [0,0] }
        transaction do
          stamp("test_stamp")
        end
      end
      pdf.render.should =~ /\/Stamp1 Do/
    end

    it "should properly rollback when #rollback is called" do
      pdf = Prawn::Document.new do
        create_stamp("test_stamp") { draw_text "This is not shown", :at => [0,0] }

        transaction do
          stamp("test_stamp")
          rollback
        end
      end
      pdf.render.should.not =~ /\/Stamp1 Do/
    end 

  end

  it "should restore page_number on rollback" do
    Prawn::Document.new do
      transaction do
        5.times { start_new_page }
        rollback
      end

      page_number.should == 1
    end
  end

end

