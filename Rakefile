require 'rubygems'
require 'rake'
require 'rake/testtask'
require "rake/rdoctask"
require "rake/gempackagetask"  

PRAWN_LAYOUT_VERSION = "0.8.0" 

task :default => [:test]
       
desc "Run all tests, test-spec and mocha required"
Rake::TestTask.new do |test|
  test.libs << "spec"
  test.test_files = Dir[ "spec/*_spec.rb" ]
  test.verbose = true
end

desc "Show library's code statistics"
task :stats do
	require 'code_statistics'
	CodeStatistics.new( ["prawn-layout", "lib"], 
	                    ["Specs", "spec"] ).to_s
end

desc "genrates documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README", "lib/" )
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

spec = Gem::Specification.new do |spec|
  spec.name = "prawn-layout"
  spec.version = PRAWN_LAYOUT_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "An extension to Prawn that provides table support and other layout functionality"
  spec.files =  Dir.glob("{examples,lib,spec,vendor,data}/**/**/*") +
                      ["Rakefile"]
  spec.require_path = "lib"
  
  spec.test_files = Dir[ "test/*_test.rb" ]
  spec.has_rdoc = true
  spec.extra_rdoc_files = %w{README}
  spec.rdoc_options << '--title' << 'Prawn Documentation' <<
                       '--main'  << 'README' << '-q'
  spec.author = "Gregory Brown"
  spec.email = "  gregory.t.brown@gmail.com"
  spec.rubyforge_project = "prawn"
  spec.homepage = "http://prawn.majesticseacreature.com"
  spec.description = <<END_DESC
  An extension to Prawn that provides table support and other layout functionality
END_DESC
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
