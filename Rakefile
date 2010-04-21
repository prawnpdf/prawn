require 'rubygems'
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

desc "run all examples, and then diff them against reference PDFs"
task :examples do 
  mkdir_p "output"
  examples = Dir["examples/**/*.rb"]
  t = Time.now
  puts "Running Examples"
  examples.each { |file| `ruby -Ilib #{file}` }  
  puts "Ran in #{Time.now - t} s"        
  `mv *.pdf output`                     
end

spec = Gem::Specification.load "prawn.gemspec"
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

