require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

describe "Outline" do
  before(:each) do
    @pdf = Prawn::Document.new() do
      text "Page 1. This is the first Chapter. "
      start_new_page
      text "Page 2. More in the first Chapter. "
      start_new_page
      define_outline do
        section 'Chapter 1', :page => 1, :closed => true do 
          page 1, :title => 'Page 1'
          page 2, :title => 'Page 2'
        end
      end
    end
  end
  describe "#generate_outline" do 
    before(:each) do
      render_and_find_objects
    end
  
    it "should create a root outline dictionary item" do
      assert_not_nil @outline_root
    end
    
    it "should set the first and last top items of the root outline dictionary item" do
      referenced_object(@outline_root[:First]).should == @section_1
      referenced_object(@outline_root[:Last]).should == @section_1
    end
  
    describe "#create_outline_item" do
      it "should create outline items for each section and page" do
        [@section_1, @page_1, @page_2].each {|item| assert_not_nil item}
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
        @section_1[:Count].should.abs == 2
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
  
  describe "#outline.add_section" do
    before(:each) do
      @pdf.start_new_page
      @pdf.text "Page 3. An added section "
      @pdf.outline.add_section do
        section 'Added Section', :page => 3 do
          page 3, :title => 'Page 3'
        end
      end
      render_and_find_objects
    end
    
    it "should add new outline items to document" do
      [@section_2, @page_3].each { |item| assert_not_nil item}
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
  
  describe "#outline.insert_section_after" do
    describe "inserting in the middle of another section" do
      before(:each) do
        @pdf.go_to_page 1
        @pdf.start_new_page
        @pdf.text "Inserted Page"
        @pdf.outline.insert_section_after 'Page 1' do 
          page page_number, :title => "Inserted Page"
        end
        render_and_find_objects
      end

      it "should insert new outline items to document" do
        assert_not_nil @inserted_page
      end

      it "should adjust the count of all ancestors" do    
        @outline_root[:Count].should == 4
        @section_1[:Count].should.abs == 3
      end
      
      describe "#adjust_relations" do
        
        it "should reset the sibling relations of adjoining items to inserted item" do
          referenced_object(@page_1[:Next]).should == @inserted_page
          referenced_object(@page_2[:Prev]).should == @inserted_page
        end

        it "should set the sibling relation of added item to adjoining items" do
          referenced_object(@inserted_page[:Next]).should == @page_2
          referenced_object(@inserted_page[:Prev]).should == @page_1
        end
        
        it "should not affect the first and last relations of parent item" do
          referenced_object(@section_1[:First]).should == @page_1
          referenced_object(@section_1[:Last]).should == @page_2
        end
        
      end
      
    end
    
    describe "inserting at the end of another section" do
      before(:each) do
        @pdf.go_to_page 2
         @pdf.start_new_page
         @pdf.text "Inserted Page"
         @pdf.outline.insert_section_after 'Page 2' do 
           page page_number, :title => "Inserted Page"
         end
         render_and_find_objects
      end
      
      describe "#adjust_relations" do
        
        it "should reset the sibling relations of adjoining item to inserted item" do
           referenced_object(@page_2[:Next]).should == @inserted_page
        end

        it "should set the sibling relation of added item to adjoining items" do
          assert_nil referenced_object(@inserted_page[:Next])
          referenced_object(@inserted_page[:Prev]).should == @page_2
        end
        
        it "should adjust the last relation of parent item" do
          referenced_object(@section_1[:Last]).should == @inserted_page
        end

      end
    end
    
    it "should require an existing title" do 
      assert_raise Prawn::Errors::UnknownOutlineTitle do
        @pdf.go_to_page 1
        @pdf.start_new_page
        @pdf.text "Inserted Page"
        @pdf.outline.insert_section_after 'Wrong page' do 
          page page_number, :title => "Inserted Page"
        end
        render_and_find_objects
      end
    end
    
  end
  
  describe "#page" do
    it "should require a title option to be set" do
      assert_raise Prawn::Errors::RequiredOption do
        @pdf = Prawn::Document.new() do
          text "Page 1. This is the first Chapter. "
          define_outline do
            page 1, :title => nil
          end
        end
      end
    end
  end
end

def render_and_find_objects
  output = StringIO.new(@pdf.render, 'r+')
  @hash = PDF::Hash.new(output)
  @outline_root = @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Outlines}
  @pages = @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Pages}[:Kids]
  @section_1 = find_by_title('Chapter 1')
  @page_1 = find_by_title('Page 1')
  @page_2 = find_by_title('Page 2')
  @section_2 = find_by_title('Added Section')
  @page_3 = find_by_title('Page 3')
  @inserted_page = find_by_title('Inserted Page')
end

def find_by_title(title)
  @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Title] == title}
end

def referenced_object(reference)
  @hash[reference]
end
  
