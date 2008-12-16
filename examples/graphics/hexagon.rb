# encoding: utf-8
#
# Draws and fills a Hexagon using Document#polygon
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"

pdf = Prawn::Document.new
                        
pdf.fill_color "ff0000"
pdf.fill_polygon [100, 250], [200, 300], [300, 250],
                 [300, 150], [200, 100], [100, 150]            

pdf.render_file "hexagon.pdf"