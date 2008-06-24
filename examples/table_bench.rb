require "rubygems"
require "pdf/writer"
require "pdf/simpletable"
require "fastercsv"
require "benchmark"

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

csv_data = FasterCSV.read("#{Prawn::BASEDIR}/examples/currency.csv") * 
  (ARGV.first || 1).to_i

####################################
# PDF::Writer Table Rendering Prep #
####################################
pdf = PDF::Writer.new
pdf.select_font("Helvetica")

table = PDF::SimpleTable.new do |tab|
  tab.column_order.push(*%w(date rate))

  tab.columns["date"] = PDF::SimpleTable::Column.new("date") { |col|
    col.heading = "Date"
  }
  tab.columns["rate"] = PDF::SimpleTable::Column.new("rate") { |col|
    col.heading = "Rate"
  }

  tab.orientation   = :center
  tab.shade_rows    = :none

  data = csv_data.map do |e| 
    { "date" => e[0], "rate" => e[1] }
  end

  tab.data.replace data
end

##############################
# Prawn Table Rendering Prep #
##############################
doc = Prawn::Document.new

#######################
# Benchmarking code   #
#######################

puts "Processing #{csv_data.length} records"

Benchmark.bmbm do |x|
  x.report("Prawn") do
    doc.table(csv_data, :font_size => 10, :padding => 2, :position => :center,
                        :headers   => ["Date","Rate"])
    doc.render_file('currency_prawn.pdf')
  end
  x.report("PDF Writer") do
    table.render_on(pdf) 
    pdf.save_as('currency_pdf_writer.pdf')
  end
end
