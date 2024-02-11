# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Horizontal Positioning'

  text do
    prose <<~TEXT
      The image may be positioned relatively to the current bounding box. The
      horizontal position may be set with the <code>:position</code> option.

      It may be <code>:left</code>, <code>:center</code>, <code>:right</code>
      or a number representing an x-offset from the left boundary.
    TEXT
  end

  example new_page: true do
    bounding_box([50, cursor], width: 400, height: 450) do
      stroke_bounds

      %i[left center right].each do |position|
        text "Image aligned to the #{position}."
        image "#{Prawn::DATADIR}/images/stef.jpg", position: position
      end

      text 'The next image has a 50 point offset from the left boundary'
      image "#{Prawn::DATADIR}/images/stef.jpg", position: 50
    end
  end
end
