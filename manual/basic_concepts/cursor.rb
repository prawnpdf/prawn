# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Cursor'

  text do
    prose <<~TEXT
      We normally write our documents from top to bottom and it is no different
      with Prawn. Even if the origin is on the bottom left corner we still fill
      the page from the top to the bottom. In other words the cursor for
      inserting content starts on the top of the page.

      Most of the functions that insert content on the page will start at the
      current cursor position and proceed to the bottom of the page.

      The following snippet shows how the cursor behaves when we add some text
      to the page and demonstrates some of the helpers to manage the cursor
      position. The <code>cursor</code> method returns the current cursor
      position.
    TEXT
  end

  example axes: true do
    text "the cursor is here: #{cursor}"
    text "now it is here: #{cursor}"

    move_down 100
    text "on the first move the cursor went down to: #{cursor}"

    move_up 50
    text "on the second move the cursor went up to: #{cursor}"

    move_cursor_to 50
    text "on the last move the cursor went directly to: #{cursor}"
  end
end
