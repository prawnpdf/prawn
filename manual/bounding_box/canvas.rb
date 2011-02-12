# encoding: utf-8
# 
# The origin example already mentions that a new document already comes with
# a margin box whose bottom left corner is used as the origin for calculating
# coordinates.
#
# What has not been told is that there is one helper for "bypassing" the margin
# box: <code>canvas</code>. This method is a shortcut for creating a bounding
# box mapped to the absolute coordinates and evaluating the code inside it.
#
# The following snippet draws a circle on each of the four absolute corners.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  canvas do
    fill_circle_at [bounds.left, bounds.top],     :radius => 30
    fill_circle_at [bounds.right, bounds.top],    :radius => 30
    fill_circle_at [bounds.right, bounds.bottom], :radius => 30
    fill_circle_at [0, 0],                        :radius => 30
  end
end
