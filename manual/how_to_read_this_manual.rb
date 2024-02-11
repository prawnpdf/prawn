# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    doc.move_down(Prawn::ManualBuilder::INNER_MARGIN)

    header('How to read this manual')

    prose <<~END_TEXT
      This manual is a collection of examples categorized by theme and
      organized from the least to the most complex. While it covers most of the
      common use cases it is not a comprehensive guide.

      The best way to read it depends on your previous knowledge of Prawn and
      what you need to accomplish.

      If you are beginning with Prawn the first chapter will teach you the most
      basic concepts and how to create pdf documents. For an overview of the
      other features each chapter beyond the first either has a Basics section
      (which offer enough insight on the feature without showing all the
      advanced stuff you might never use) or is simple enough with only a few
      examples.

      Once you understand the basics you might want to come back to this manual
      looking for examples that accomplish tasks you need.

      Advanced users are encouraged to go beyond this manual and read the
      source code directly if any doubt is not directly covered on this manual.
    END_TEXT

    doc.move_down(Prawn::ManualBuilder::RHYTHM + Prawn::ManualBuilder::INNER_MARGIN)
    header('Reading the examples')

    prose <<~END_TEXT
      The title of each example is the relative path from the Prawn source
      <code>manual/</code> folder.

      The first body of text is the introductory text for the example.
      Generally it is a short description of the features illustrated by the
      example.

      Next comes the example source code block in fixed width font.

      Most of the example snippets illustrate features that alter the page in
      place. The effect of these snippets is shown right below a dashed line.
      If it doesn't make sense to evaluate the snippet inline, a box with the
      link for the example file is shown instead.

      Note that the <code>stroke_axis</code> method used throughout the manual
      is part of standard Prawn. It is defined in this file:

      https://github.com/prawnpdf/prawn/blob/master/lib/prawn/graphics.rb
    END_TEXT
  end
end
