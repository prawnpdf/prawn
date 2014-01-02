require "bundler"
Bundler.setup

require 'rake'
require 'rspec/core/rake_task'
require 'yard'
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
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', '-', 'README.md', 
               'COPYING', 'LICENSE', 'CONTRIBUTING.md']   # optional
  t.options = ['--main', 'README.md', '--output-dir', 'doc/html', 
               '--title', 'Prawn Documentation']
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
