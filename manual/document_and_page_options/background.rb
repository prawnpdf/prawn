# encoding: utf-8
#
# Pass an image path to the <code>:background</code> option and it will be used
# as the background for all pages.
# This option can only be used on document creation.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

img = "#{Prawn::DATADIR}/images/letterhead.jpg"

Prawn::Document.generate("background.pdf",
                         :background => img,
                         :margin => 100
) do
  text "My report caption", :size => 18, :align => :right

  move_down font.height * 2

  text "Here is my text explaning this report. " * 20,
       :size => 12, :align => :left, :leading => 2

  move_down font.height

  text "I'm using a soft background. " * 40,
       :size => 12, :align => :left, :leading => 2
end
