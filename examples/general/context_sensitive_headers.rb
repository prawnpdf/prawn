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
  meetings.each_with_index do |meeting,i|
    
    create_stamp(meeting.to_s) do
      canvas do
        text_box("header for #{meeting}",
          :at => [bounds.left + 50, bounds.top - 20],
          :height => 50,
          :width => margin_box.width)
      end
    end
    on_page_create { stamp(meeting.to_s) }

    start_new_page

    #simulate some meetings with content over multiple pages
    (15 + 20*i).times do |i|
      text "#{meeting} attendee #{i}"
    end
    
  end

end

