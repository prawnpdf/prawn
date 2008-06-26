require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require "rake/rdoctask"

task :default => [:spec]

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

desc "Show library's code statistics"
task :stats do
	require 'code_statistics'
	CodeStatistics.new( ["Prawn", "lib"], 
	                    ["Specs",     "spec"] ).to_s
end

desc "genrates documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README",
                           "COPYING",
                           "LICENSE", "lib/" )
  rdoc.main     = "README"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "Prawn Documentation"
end



