# encoding: utf-8
#
# A text box is positioned by a top-left corner, width, and height and is
# essentially an invisible rectangle that the text will flow within.  If the
# text exceeds the boundaries, it is either truncated, replaced with some
# ellipses, or set to expand beyond the bottom boundary.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("text_box_returning_excess.pdf") do

  # Note that without the initial space in p_break, newlines may be eaten by
  # the wrap/unwrap process that happens inside the text box.
  p_break = " \n\n"
  callout = "Lorem ipsum dolor sit amet"
  lorem   = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.#{p_break}Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.#{p_break}Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

  box_height = font.height * 5

  # Add a callout box that the rest of the text should flow around
  font_size(18) do
    text_box callout, {
      :width    => 100,
      :height   => font.height * 3,
      :overflow => :truncate,
      :at       => [100, bounds.top - box_height - 4]
    }
  end

  excess_text = text_box lorem + p_break + lorem, {
    :width    => 300,
    :height   => box_height,
    :overflow => :truncate,
    :at       => [100, bounds.top],
  }

  excess_text = text_box excess_text, {
    :width    => 200,
    :height   => box_height,
    :overflow => :truncate,
    :at       => [200, bounds.top - box_height],
  }

  text_box excess_text, {
    :width    => 300,
    :height   => box_height,
    :overflow => :expand,
    :at       => [100, bounds.top - box_height * 2],
  }

end
