# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("table_alignment.pdf") do
  rows = [:top, :middle, :bottom].map do |valign|
    [:left, :center, :right].map do |align|
      Prawn::Graphics::Cell.new(
        :text => 'Lorem ipsum ' * 5,
        :align => align,
        :valign => valign,
        :height => 90
      )
    end
  end

  table rows,
    :font_size  => 12, 
    :horizontal_padding => 3,
    :vertical_padding   => 3,
    :border_width       => 2,
    :border_style       => :grid,
    :position           => :center,
    :widths => {0 => 180, 1 => 180, 2 => 180}
end
