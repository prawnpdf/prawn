# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Vertical Positioning'

  text do
    prose <<~TEXT
      To set the vertical position of an image use the <code>:vposition</code>
      option.

      It may be <code>:top</code>, <code>:center</code>, <code>:bottom</code>
      or a number representing the y-offset from the top boundary.
    TEXT
  end

  example new_page: true do
    bounding_box([0, cursor], width: 500, height: 450) do
      stroke_bounds

      %i[top center bottom].each do |vposition|
        text "Image vertically aligned to the #{vposition}.", valign: vposition
        image "#{Prawn::DATADIR}/images/stef.jpg",
          position: 220,
          vposition: vposition
      end

      text_box 'The next image has a 100 point offset from the top boundary',
        at: [bounds.width - 110, bounds.top - 10],
        width: 100
      image "#{Prawn::DATADIR}/images/stef.jpg",
        position: :right,
        vposition: 100
    end
  end
end
