require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper") 

describe "Outline#generate_outline" do 
  before(:each) do
    pdf = Prawn::Document.new() do
      text "Page 1. This is the first Chapter. "
      start_new_page
      text "Page 2. More in the first Chapter. "
      start_new_page
      text "Page 3. This is the second Chapter. It has a subsection. "
      start_new_page
      text  "Page 4. More in the second Chapter. "
      render_outline do
        section 'Chapter 1', :page => 1, :closed => true do 
          page 'Page 1', :page => 1
          page 'Page 2', :page => 2
        end
        section 'Chapter 2', :page => 3 do 
          section 'Chapter 2 Subsection' do
            page 'Page 3', :page => 3
          end
          page 'Page 4', :page => 4
        end
      end
      start_new_page
      text "Page 5. Appendix"
      start_new_page 
      text "Page 6. More in the Appendix"
      add_outline_section do
        section 'Appendix', :page => 5 do
          page 'Page 5', :page => 5
          page 'Page 6', :page => 6
        end
      end
    end
    output = StringIO.new(pdf.render, 'r+')
    @hash = PDF::Hash.new(output)
    @outline_root = @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Outlines}
    @pages = @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Pages}[:Kids]
    @first = @hash[@outline_root[:First]]
  end
  
  it "the outline root should have a count of 10" do
    @outline_root[:Count].should == 10
  end
  
  it "the first outline item should have a Chapter 1 title" do
    @first[:Title].should == 'Chapter 1'
  end
  
  it "the first outline item's last item should have a destination of Page 2" do
   last = @first[:Last]
   @hash[last][:Dest][0].should == @pages[1]
  end
  
  it "page 3's great grand parent should be the outline_root" do
    page_3 = @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Title] == 'Page 3'}
    @great_grand_parent = [1, 2].inject(page_3[:Parent]) { |parent, d| @hash[parent][:Parent] } 
    @hash[@great_grand_parent].should == @outline_root
  end

end