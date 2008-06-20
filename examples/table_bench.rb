require "rubygems"
require "pdf/writer"
require "pdf/simpletable"
gem "pdf-wrapper", ">=0.1.2"
require "pdf/wrapper"
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
    col.heading = "rate"
  }

  tab.show_lines    = :all
  tab.show_headings = false
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

##############################
# PDF::Wrapper Table Rendering Prep
##############################
wrapper_doc = PDF::Wrapper.new
wrapper_table = PDF::Wrapper::Table.new do |t|
  t.data = csv_data
  t.table_options :font_size => 6
end

#######################
# Benchmarking code   #
#######################

puts "Processing #{csv_data.length} records"

Benchmark.bmbm do |x|
  x.report("PDF Wrapper") do
    wrapper_doc.table( wrapper_table, :width => 100 ) unless wrapper_doc.finished?
    wrapper_doc.render_to_file('currency_pdf_wrapper.pdf')
  end
  x.report("Prawn") do
    doc.table(csv_data, :font_size => 10, :padding => 2, :position => :center)
    doc.render_file('currency_prawn.pdf')
  end
  x.report("PDF Writer") do
    table.render_on(pdf) 
    pdf.save_as('currency_pdf_writer.pdf')
  end
end
