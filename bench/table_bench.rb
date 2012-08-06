if RUBY_VERSION =~ /1\.8/
  require "rubygems"
  class Array
    def sample
      self[rand(self.length)]
    end
  end
end

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

def benchmark_table_generation(columns,rows,string_size)
  data = data_for_table(columns,rows,string_size)
  Benchmark.bm do |x|
    x.report("#{columns}x#{rows} table (#{columns*rows} cells, with #{string_size} char string contents)") do
      Prawn::Document.new { table(data) }.render             
    end
  end
end

benchmark_table_generation(10,450,5)
benchmark_table_generation(10,300,5)
benchmark_table_generation(10,200,5)
benchmark_table_generation(10,150,5)
benchmark_table_generation(10,100,5)
benchmark_table_generation(10,50,5)
benchmark_table_generation(10,25,5)

benchmark_table_generation(20,100,5)
benchmark_table_generation(25,80,5)
