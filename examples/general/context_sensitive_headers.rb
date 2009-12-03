require "#{File.dirname(__FILE__)}/../example_helper.rb"

# Ex. Generate a roster of meeting attendees given a set of meetings.
# Attendees for a meeting may overflow to accross page boundaries but 
# each meeting starts on a separate page. Each page for any given
# meeting will have the heading for that meeting. 

#dummying up some meetings
meetings = []
5.times do |i|
  meetings << "Meeting number #{i}"
end

Prawn::Document.generate('context_sensitive_headers.pdf', :margin => [100, 100], :skip_page_creation => true) do
  @page2header = {}
  
  before_new_page do
    @page2header[page_count + 1] = @current_meeting
  end
  
  meetings.each do |meeting|
    @current_meeting = meeting
    
    repeat lambda {|pn| @page2header[pn] == meeting } do
      canvas do
        bounding_box([bounds.left + 50, bounds.top - 20], :height => 50, :width => margin_box.width) do
          text "header for #{meeting}"
        end
      end

    end
    
    start_new_page
    
    #simulate some meetings with content over multiple pages
    rand(100).times do |i|
      text "#{meeting} attendee #{i}"
    end
  end
  
end

