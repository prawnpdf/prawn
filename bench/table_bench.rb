# encoding: utf-8

require "benchmark"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "prawn"

csv_data = nil

ruby_18 do
  require "rubygems"
  require "fastercsv"
  csv_data = FasterCSV.read("#{Prawn::BASEDIR}/examples/table/currency.csv") * 
    (ARGV.first || 1).to_i
end

ruby_19 do
  require "csv"
  csv_data = CSV.read("#{Prawn::BASEDIR}/examples/table/currency.csv") * 
    (ARGV.first || 1).to_i
end

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
