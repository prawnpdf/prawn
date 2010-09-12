bounding_box([bounds.left+10, cursor-10], :width => bounds.width-20, :height => 200) do
  fill_color "ff0000"
  fill_polygon [0, 150], [100, 200], [200, 150],
               [200, 50], [100, 0], [0, 50]
end
