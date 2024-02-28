# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    header_with_bg('Images')

    prose <<-TEXT
      Embedding images on PDF documents is fairly easy. Prawn supports both JPG
      and PNG images.

      The examples show:
    TEXT

    list(
      'How to add an image to a page',
      'How place the image on a specific position',
      'How to configure the image dimensions by setting the width and ' \
        'height or by scaling it',
    )
  end
end
