require "rubygems"
require "bundler"
Bundler.setup

require 'rake'
require 'rake/testtask'
require "rake/rdoctask"
require "rake/gempackagetask"  

task :default => [:test]
       
desc "Run all tests, test-spec, mocha, and pdf-reader required"
Rake::TestTask.new do |test|
  # test.ruby_opts  << "-w"  # .should == true triggers a lot of warnings
  test.libs       << "spec"
  test.test_files =  Dir[ "spec/*_spec.rb" ]
  test.verbose    =  true
end

desc "Show library's code statistics"
task :stats do
	require 'code_statistics'
  CodeStatistics::TEST_TYPES << "Specs"	
	CodeStatistics.new( ["Prawn", "lib"], 
	                    ["Specs", "spec"] ).to_s
end

desc "genrates documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README",
                           "COPYING",
                           "LICENSE", 
                           "HACKING", "lib/" )
  rdoc.main     = "README"
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
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
