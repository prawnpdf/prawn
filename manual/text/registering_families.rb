# encoding: utf-8
#
# Registering font families will help you when you want to use a font over and
# over or if you would like to take advantage of the <code>:style</code> option
# of the text methods and the <code>b</code> and <code>i</code> tags when using
# inline formatting.
#
# To register a font family update the <code>font_families</code>
# hash with the font path for each style you want to use.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::ManualBuilder::Example.generate(filename) do
  # Registering a single TTF font
  font_families.update("DejaVu Sans" => {
    :normal => "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
  })

  font("DejaVu Sans") do
    text "Using the DejaVu Sans font providing only its name to the font method"
  end
  move_down 20

  # Registering a DFONT package
  font_path = "#{Prawn::DATADIR}/fonts/Panic+Sans.dfont"
  font_families.update("Panic Sans" => {
    :normal      => { :file => font_path, :font => "PanicSans" },
    :italic      => { :file => font_path, :font => "PanicSans-Italic" },
    :bold        => { :file => font_path, :font => "PanicSans-Bold" },
    :bold_italic => { :file => font_path, :font => "PanicSans-BoldItalic" }
  })

  font "Panic Sans"
  text "Also using Panic Sans by providing only its name"
  move_down 20

  text "Taking <b>advantage</b> of the <i>inline formatting</i>",
       :inline_format => true
  move_down 20

  [:bold, :bold_italic, :italic, :normal].each do |style|
    text "Using the #{style} style option.",
         :style => style
    move_down 10
  end
end
