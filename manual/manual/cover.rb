# encoding: utf-8
#
# Prawn manual how to read this manual page. 
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  move_down 200

  image "#{Prawn::BASEDIR}/data/images/prawn.png",
        :scale => 0.9,
        :at => [10, cursor]
        
  formatted_text_box([ {:text => "Prawn\n",
                        :styles => [:bold],
                        :size => 100}
                     ], :at => [170, cursor - 50])

  formatted_text_box([ {:text => "by example",
                        :font => 'Courier',
                        :size => 60}
                     ], :at => [170, cursor - 160])
  
end
