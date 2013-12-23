require "bundler"
Bundler.setup

require 'rake'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'rubygems/package_task'

task :default => [:spec]

desc "Run all rspec files"
RSpec::Core::RakeTask.new("spec") do |c|
  c.rspec_opts = "-t ~unresolved"
end

desc "Show library's code statistics"
task :stats do
  require 'code_statistics'
  CodeStatistics::TEST_TYPES << "Specs"
  CodeStatistics.new( ["Prawn", "lib"],
                      ["Specs", "spec"] ).to_s
end

desc "genrates documentation"
RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include( "README.md",
                           "COPYING",
                           "LICENSE",
                           "lib/" )
  rdoc.main     = "README.md"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "Prawn Documentation"
end

desc "Generate the 'Prawn by Example' manual"
task :manual do
  puts "Building manual..."
  require File.expand_path(File.join(File.dirname(__FILE__),
    %w[manual manual manual]))
  puts "The Prawn manual is available at manual.pdf. Happy Prawning!"
end

spec = Gem::Specification.load "prawn.gemspec"
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
