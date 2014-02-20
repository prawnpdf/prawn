# encoding: utf-8

require_relative "spec_helper"

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

  it "should reset page count if transaction is rolled back", 
    :unresolved, :issue => 268 do
    pdf = Prawn::Document.new do 
      transaction do 
        start_new_page
        start_new_page
        start_new_page
        rollback
      end
    end

    pdf.page_count.should == 1
  end

  it "should not affect colorspace count if transaction is rolling back",
    :unresolved, :issue => 268 do

    pdf = Prawn::Document.new do
      transaction do
        stroke_color "ff0000"
        5.times { start_new_page }
        rollback
      end

      stroke_color "ff0000"
    end
    
    colors = PDF::Inspector::Graphics::Color.analyze(pdf.render)
    colors.stroke_color_space_count[:DeviceRGB].should == 1
  end


  it "should not impact page numbering if transaction is rolled back",
    :unresolved, :issue => 268 do
      pdf = Prawn::Document.new(:skip_page_creation => true)   

      pdf.transaction do
        5.times { pdf.start_new_page }
        pdf.rollback # Comment this line
      end
     
      5.times { pdf.start_new_page }
     
      pdf.number_pages 'Page <page> of <total>', { :at => [pdf.bounds.bottom + 300, 15] }
      text = PDF::Inspector::Text.analyze(pdf.render)

      text.strings.select { |e| e[/Page \d+ of 5/] }.count.should == 5
  end

  it "should restore the total page count if a transaction is rolled back",
    :unresolved, :issue => 268 do

    pdf = Prawn::Document.new do
      transaction do
        5.times { start_new_page }
        rollback
      end
    end

    pdf.page_count.should == 1
  end

  it "should not include rolled back page objects in PDF document",
    :unresolved, :issue => 268 do
    pdf = Prawn::Document.new do
      transaction do
        5.times { start_new_page }
        text "way out there and will never be shown"
        rollback
      end
      text "This is the real text, only one page"
    end


    # FIXME: Belongs in PDF::Inspector. Also look for
    # similar tests that may need to be rewritten this way.
    page_count = PDF::Reader.new(StringIO.new(pdf.render))
                   .objects
                   .select { |k,v| Hash === v && v[:Type] == :Page }.count

    page_count.should == 1
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

  it "should not propagate a RollbackTransaction outside its bounds" do
    def add_lines(pdf)
      100.times { |i| pdf.text "Line #{i}" }
    end

    Prawn::Document.new do |pdf|
      lambda do
        begin
          pdf.group { add_lines(pdf) }
        rescue Prawn::Errors::CannotGroup
          add_lines(pdf)
        end
      end.should_not raise_error#(Prawn::Document::Snapshot::RollbackTransaction)
    end
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

  it "should restore bounds on rollback" do
    Prawn::Document.new(:page_layout => :landscape) do
      size = [bounds.width, bounds.height]
      transaction do
        start_new_page :layout => :portrait
        rollback
      end
      [bounds.width, bounds.height].should == size
    end
  end

  it "should set new bounding box on start_new_page with different layout" do
    Prawn::Document.new(:page_layout => :landscape) do
      size = [bounds.width, bounds.height]
      transaction do
        start_new_page
        rollback
      end

      start_new_page :layout => :portrait
      [bounds.width, bounds.height].should == size.reverse
    end
  end

  it "should work with dests" do
    Prawn::Document.new do |pdf|
      pdf.add_dest("dest", pdf.dest_fit_horizontally(pdf.cursor, pdf.page))
      pdf.text("Hello world")
      lambda { pdf.transaction{} }.should_not raise_error
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
      pdf.render.should_not =~ /\/Stamp1 Do/
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

