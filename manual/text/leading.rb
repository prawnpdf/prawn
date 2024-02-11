# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Leading'

  text do
    prose <<~TEXT
      Leading is the additional space between lines of text.

      The leading can be set using the <code>default_leading</code> method
      which applies to the rest of the document or until it is changed, or
      inline in the text methods with the <code>:leading</code> option.

      The default leading is <code>0</code>.
    TEXT
  end

  example do
    string = 'Hey, what did you do with the space between my lines? ' * 8
    text string, leading: 0

    move_down 20
    default_leading 5
    text string

    move_down 20
    text string, leading: 10
  end
end
