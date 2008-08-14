# encoding: utf-8

require "rubygems"
require "fastercsv"
require "benchmark"

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

csv_data = FasterCSV.read("#{Prawn::BASEDIR}/examples/currency.csv") * 
  (ARGV.first || 1).to_i

doc = Prawn::Document.new

#######################
# Benchmarking code   #
#######################

puts "Processing #{csv_data.length} records"

Benchmark.bmbm do |x|

  x.report("Prawn") do
    doc.table(csv_data, :font_size          => 10, 
                        :vertical_padding   => 2,
                        :horizontal_padding => 5, 
                        :position           => :center, 
                        :row_colors         => :pdf_writer,
                        :headers            => ["Date","Rate"])
    doc.render_file('currency_prawn.pdf')
  end
end
