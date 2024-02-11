# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Fiting'

  text do
    prose <<~TEXT
      <code>:fit</code> option is useful when you want the image to have the
      maximum size within a container preserving the aspect ratio without
      overlapping.

      Just provide the container width and height pair.
    TEXT
  end

  example do
    size = 300

    text 'Using the fit option'
    bounding_box([0, cursor], width: size, height: size) do
      image "#{Prawn::DATADIR}/images/pigs.jpg", fit: [size, size]
      stroke_bounds
    end
  end
end
