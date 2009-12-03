require "#{File.dirname(__FILE__)}/../example_helper.rb"

# Generating a roster of students for a set of classes. Content for 
# each class may overflow to multiple pages but each class should 
# start on a separate page. Each page should have header for correct
# class.

#dummying up some classes
classes = []
5.times do |i|
  classes << "Class number #{i}"
end

Prawn::Document.generate('context_sensitive_headers.pdf', :margin => [100, 100], :skip_page_creation => true) do
  @page2header = {}
  
  before_new_page do
    @page2header[page_count + 1] = @current_class
  end
  
  classes.each do |klass|
    @current_class = klass
    
    repeat lambda {|pn| @page2header[pn] == klass } do
      canvas do
        bounding_box([bounds.left + 50, bounds.top - 20], :height => 50, :width => margin_box.width) do
          text "header for #{klass}"
        end
      end

    end
    
    start_new_page
    
    

    #simulate some classes with content over multiple pages
    rand(100).times do |i|
      text "#{klass} student #{i}"
    end
  end
  
end

