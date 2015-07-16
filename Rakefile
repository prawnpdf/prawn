require "bundler"
Bundler.setup

require 'rake'
require 'rspec/core/rake_task'
require 'yard'
require 'rubygems/package_task'
require 'rubocop/rake_task'

task :default => [:spec, :rubocop]

desc "Run all rspec files"
RSpec::Core::RakeTask.new("spec") do |c|
  c.rspec_opts = "-t ~unresolved"
end

desc "Show library's code statistics"
task :stats do
  require 'code_statistics/code_statistics'
  puts CodeStatistics::CodeStatistics.new(
    [
      ["Prawn", "lib"],
      ["Specs", "spec"]
    ]
  ).to_s
end

YARD::Rake::YardocTask.new do |t|
  t.options = ['--output-dir', 'doc/html']
end
task :docs => :yard

desc "Generate the 'Prawn by Example' manual"
task :manual do
  puts "Building manual..."
  require File.expand_path(File.join(File.dirname(__FILE__), %w[manual contents]))
  puts "The Prawn manual is available at manual.pdf. Happy Prawning!"
end

spec = Gem::Specification.load "prawn.gemspec"
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Run a console with Prawn loaded"
task :console do
  require 'irb'
  require 'irb/completion'
  require_relative 'lib/prawn'
  Prawn.debug = true

  ARGV.clear
  IRB.start
end

RuboCop::RakeTask.new
