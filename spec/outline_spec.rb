# encoding: utf-8
require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Outline" do
  before(:each) do
    @pdf = Prawn::Document.new() do
      text "Page 1. This is the first Chapter. "
      start_new_page
      text "Page 2. More in the first Chapter. "
      start_new_page
      outline.define do
        section 'Chapter 1', :destination => 1, :closed => true do
          page :destination => 1, :title => 'Page 1'
          page :destination => 2, :title => 'Page 2'
        end
      end
    end
  end

  describe "outline encoding" do
    it "should store all outline titles as UTF-16" do
      render_and_find_objects
      @hash.values.each do |obj|
        if obj.is_a?(Hash) && obj[:Title]
          title = obj[:Title].dup
          title.force_encoding(Encoding::UTF_16LE)
          title.valid_encoding?.should == true
        end
      end
    end
  end

  describe "#generate_outline" do
    before(:each) do
      render_and_find_objects
    end

    it "should create a root outline dictionary item" do
      @outline_root.should_not be_nil
    end

    it "should set the first and last top items of the root outline dictionary item" do
      referenced_object(@outline_root[:First]).should == @section_1
      referenced_object(@outline_root[:Last]).should == @section_1
    end

    describe "#create_outline_item" do
      it "should create outline items for each section and page" do
        [@section_1, @page_1, @page_2].each {|item| item.should_not be_nil}
      end
    end

    describe "#set_relations, #set_variables_for_block, and #reset_parent" do
      it "should link sibling items" do
        referenced_object(@page_1[:Next]).should == @page_2
        referenced_object(@page_2[:Prev]).should == @page_1
      end

      it "should link child items to parent item" do
        [@page_1, @page_2].each {|page| referenced_object(page[:Parent]).should == @section_1 }
      end

      it "should set the first and last child items for parent item" do
        referenced_object(@section_1[:First]).should == @page_1
        referenced_object(@section_1[:Last]).should == @page_2
      end
    end

    describe "#increase_count" do

      it "should add the count of all descendant items" do
        @outline_root[:Count].should == 3
        @section_1[:Count].abs.should == 2
        @page_1[:Count].should == 0
        @page_2[:Count].should == 0
      end

    end

    describe "closed option" do

      it "should set the item's integer count to negative" do
        @section_1[:Count].should == -2
      end

    end

  end

  describe "adding a custom destination" do
    before(:each) do
      @pdf.start_new_page
      @pdf.text "Page 3 with a destination"
      @pdf.add_dest('customdest', @pdf.dest_xyz(200, 200))
      pdf = @pdf
      @pdf.outline.update do
        page :destination => pdf.dest_xyz(200, 200), :title => 'Custom Destination'
      end
      render_and_find_objects
    end

    it "should create an outline item" do
      @custom_dest.should_not be_nil
    end

    it "should reference the custom destination" do
      referenced_object(@custom_dest[:Dest].first).should == referenced_object(@pages.last)
    end

  end

  describe "addding a section later with outline#section" do
    before(:each) do
      @pdf.start_new_page
      @pdf.text "Page 3. An added section "
      @pdf.outline.update do
        section 'Added Section', :destination => 3 do
          page :destination => 3, :title => 'Page 3'
        end
      end
      render_and_find_objects
    end

    it "should add new outline items to document" do
      [@section_2, @page_3].each { |item| item.should_not be_nil}
    end

    it "should reset the last items for root outline dictionary" do
      referenced_object(@outline_root[:First]).should == @section_1
      referenced_object(@outline_root[:Last]).should == @section_2
    end

    it "should reset the next relation for the previous last top level item" do
      referenced_object(@section_1[:Next]).should == @section_2
    end

    it "should set the previous relation of the addded to section" do
      referenced_object(@section_2[:Prev]).should == @section_1
    end

    it "should increase the count of root outline dictionary" do
      @outline_root[:Count].should == 5
    end

  end

  describe "#outline.add_subsection_to" do
    context "positioned last" do

      before(:each) do
        @pdf.start_new_page
        @pdf.text "Page 3. An added subsection "
        @pdf.outline.update do
          add_subsection_to 'Chapter 1' do
            section 'Added SubSection', :destination => 3 do
              page :destination => 3, :title => 'Added Page 3'
            end
          end
        end
        render_and_find_objects
      end

      it "should add new outline items to document" do
        [@subsection, @added_page_3].each { |item| item.should_not be_nil}
      end

      it "should reset the last item for parent item dictionary" do
        referenced_object(@section_1[:First]).should == @page_1
        referenced_object(@section_1[:Last]).should == @subsection
      end

      it "should set the prev relation for the new subsection to its parent's old last item" do
        referenced_object(@subsection[:Prev]).should == @page_2
      end


      it "the subsection should become the next relation for its parent's old last item" do
         referenced_object(@page_2[:Next]).should == @subsection
       end

      it "should set the first relation for the new subsection" do
        referenced_object(@subsection[:First]).should == @added_page_3
      end

      it "should set the correct last relation of the added to section" do
        referenced_object(@subsection[:Last]).should == @added_page_3
      end

      it "should increase the count of root outline dictionary" do
        @outline_root[:Count].should == 5
      end

    end

    context "positioned first" do

      before(:each) do
        @pdf.start_new_page
        @pdf.text "Page 3. An added subsection "
        @pdf.outline.update do
          add_subsection_to 'Chapter 1', :first do
            section 'Added SubSection', :destination => 3 do
              page :destination => 3, :title => 'Added Page 3'
            end
          end
        end
        render_and_find_objects
      end

      it "should add new outline items to document" do
        [@subsection, @added_page_3].each { |item| item.should_not be_nil}
      end

      it "should reset the first item for parent item dictionary" do
        referenced_object(@section_1[:First]).should == @subsection
        referenced_object(@section_1[:Last]).should == @page_2
      end

      it "should set the next relation for the new subsection to its parent's old first item" do
        referenced_object(@subsection[:Next]).should == @page_1
      end

      it "the subsection should become the prev relation for its parent's old first item" do
         referenced_object(@page_1[:Prev]).should == @subsection
       end

      it "should set the first relation for the new subsection" do
        referenced_object(@subsection[:First]).should == @added_page_3
      end

      it "should set the correct last relation of the added to section" do
        referenced_object(@subsection[:Last]).should == @added_page_3
      end

      it "should increase the count of root outline dictionary" do
        @outline_root[:Count].should == 5
      end

    end

    it "should require an existing title" do
      lambda do
        @pdf.go_to_page 1
        @pdf.start_new_page
        @pdf.text "Inserted Page"
        @pdf.outline.update do
          add_subsection_to 'Wrong page' do
            page page_number, :title => "Inserted Page"
          end
        end
        render_and_find_objects
      end.should raise_error(Prawn::Errors::UnknownOutlineTitle)
    end
  end

  describe "#outline.insert_section_after" do
    describe "inserting in the middle of another section" do
      before(:each) do
        @pdf.go_to_page 1
        @pdf.start_new_page
        @pdf.text "Inserted Page"
        @pdf.outline.update do
          insert_section_after 'Page 1' do
            page :destination => page_number, :title => "Inserted Page"
          end
        end
      end

      it "should insert new outline items to document" do
        render_and_find_objects
        @inserted_page.should_not be_nil
      end

      it "should adjust the count of all ancestors" do
        render_and_find_objects
        @outline_root[:Count].should == 4
        @section_1[:Count].abs.should == 3
      end

      describe "#adjust_relations" do

        it "should reset the sibling relations of adjoining items to inserted item" do
          render_and_find_objects
          referenced_object(@page_1[:Next]).should == @inserted_page
          referenced_object(@page_2[:Prev]).should == @inserted_page
        end

        it "should set the sibling relation of added item to adjoining items" do
          render_and_find_objects
          referenced_object(@inserted_page[:Next]).should == @page_2
          referenced_object(@inserted_page[:Prev]).should == @page_1
        end

        it "should not affect the first and last relations of parent item" do
          render_and_find_objects
          referenced_object(@section_1[:First]).should == @page_1
          referenced_object(@section_1[:Last]).should == @page_2
        end

      end


      context "when adding another section afterwards" do
        it "should have reset the root position so that a new section is added at the end of root sections" do
          @pdf.start_new_page
          @pdf.text "Another Inserted Page"
          @pdf.outline.update do
            section 'Added Section' do
              page :destination => page_number, :title => "Inserted Page"
            end
          end
          render_and_find_objects
          referenced_object(@outline_root[:Last]).should == @section_2
          referenced_object(@section_1[:Next]).should == @section_2
        end
      end

   end


    describe "inserting at the end of another section" do

      before(:each) do
        @pdf.go_to_page 2
         @pdf.start_new_page
         @pdf.text "Inserted Page"
         @pdf.outline.update do
           insert_section_after 'Page 2' do
             page :destination => page_number, :title => "Inserted Page"
           end
         end
         render_and_find_objects
      end

      describe "#adjust_relations" do

        it "should reset the sibling relations of adjoining item to inserted item" do
           referenced_object(@page_2[:Next]).should == @inserted_page
        end

        it "should set the sibling relation of added item to adjoining items" do
          referenced_object(@inserted_page[:Next]).should be_nil
          referenced_object(@inserted_page[:Prev]).should == @page_2
        end

        it "should adjust the last relation of parent item" do
          referenced_object(@section_1[:Last]).should == @inserted_page
        end

      end
    end

    it "should require an existing title" do
      lambda do
        @pdf.go_to_page 1
        @pdf.start_new_page
        @pdf.text "Inserted Page"
        @pdf.outline.update do
          insert_section_after 'Wrong page' do
            page :destination => page_number, :title => "Inserted Page"
          end
        end
        render_and_find_objects
      end.should raise_error(Prawn::Errors::UnknownOutlineTitle)
    end

  end

  describe "#page" do
    it "should require a title option to be set" do
      lambda do
        @pdf = Prawn::Document.new() do
          text "Page 1. This is the first Chapter. "
          outline.define do
            page :destination => 1, :title => nil
          end
        end
      end.should raise_error(Prawn::Errors::RequiredOption)
    end
  end
end

describe "foreign character encoding" do
  before(:each) do
    pdf = Prawn::Document.new() do
      outline.define do
        section 'La pomme croquée', :destination => 1, :closed => true
      end
    end
    @hash = PDF::Reader::ObjectHash.new(StringIO.new(pdf.render, 'r+'))
  end

  it "should handle other encodings for the title" do
    object = find_by_title('La pomme croquée')
    object.should_not == nil
  end
end

def render_and_find_objects
  output = StringIO.new(@pdf.render, 'r+')
  @hash = PDF::Reader::ObjectHash.new(output)
  @outline_root = @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Outlines}
  @pages = @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Pages}[:Kids]
  @section_1 = find_by_title('Chapter 1')
  @page_1 = find_by_title('Page 1')
  @page_2 = find_by_title('Page 2')
  @section_2 = find_by_title('Added Section')
  @page_3 = find_by_title('Page 3')
  @inserted_page = find_by_title('Inserted Page')
  @subsection = find_by_title('Added SubSection')
  @added_page_3 = find_by_title('Added Page 3')
  @custom_dest = find_by_title('Custom Destination')
end

# Outline titles are stored as UTF-16. This method accepts a UTF-8 outline title
# and returns the PDF Object that contains an outline with that name
def find_by_title(title)
  @hash.values.find {|obj|
    if obj.is_a?(Hash) && obj[:Title]
      title_codepoints = obj[:Title].unpack("n*")
      title_codepoints.shift
      utf8_title = title_codepoints.pack("U*")
      utf8_title == title ? obj : nil
    end
  }
end

def referenced_object(reference)
  @hash[reference]
end
