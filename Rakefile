require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

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

