# encoding: utf-8

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "prawn"
require "benchmark"

# Helpers for benchmark

class String
  CHARS = ("a".."z").to_a
  def self.random(length)
    length.times.collect { CHARS.sample }.join
  end
end

def data_for_table(columns,rows,string_size)
  rows.times.collect { columns.times.collect { String.random(string_size) }}
end

def benchmark_table_generation(columns,rows,string_size,options={})
  data = data_for_table(columns,rows,string_size)
  Benchmark.bm do |x|
    x.report("#{columns}x#{rows} table (#{columns*rows} cells, with #{string_size} char string contents#{", options = #{options.inspect}" unless options.empty?})") do
      Prawn::Document.new { table(data,options) }.render
    end
  end
end

# Slowest case: styled table, which is very squeezed horizontally,
#   so text has to be wrapped
benchmark_table_generation(26,50,10, :row_colors => ['FFFFFF','F0F0FF'], :header => true, :cell_style => {:inline_format=>true})

# Try building and rendering tables of different sizes
benchmark_table_generation(10,400,5)
benchmark_table_generation(10,200,5)
benchmark_table_generation(10,100,5)

# Try different optional arguments to Prawn::Document#table
benchmark_table_generation(10,450,5, :cell_style => {:inline_format=>true})
benchmark_table_generation(10,450,5, :row_colors => ['FFFFFF','F0F0FF'], :header => true, :cell_style => {:inline_format=>true})
