require 'rubygems'
require 'rake'
require 'rake/testtask'
require "rake/rdoctask"
require "rake/gempackagetask"  

# Version numbering: http://wiki.github.com/sandal/prawn/development-roadmap
PRAWN_SECURITY_VERSION = "0.1.1"

task :default => [:test]
       
desc "Run all tests, test-spec and mocha required"
Rake::TestTask.new do |test|
  test.libs << "spec"
  test.test_files = Dir[ "spec/*_spec.rb" ]
  test.verbose = true
end

desc "genrates documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README", "lib/" )
  rdoc.main     = "README"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "Prawn/Security documentation"
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
  spec.name = "prawn-security"
  spec.version = PRAWN_SECURITY_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Popular Password Protection & Permissions for Prawn PDFs"
  spec.files =  Dir.glob("{examples,lib,spec}/**/*") +
                      ["Rakefile"]
  spec.require_path = "lib"
 
  spec.test_files = Dir[ "spec/*_spec.rb" ]
  spec.has_rdoc = true
  spec.extra_rdoc_files = %w{README LICENSE COPYING}
  spec.rdoc_options << '--title' << 'Prawn/Security Documentation' <<
                       '--main'  << 'README' << '-q'
  spec.author = "Brad Ediger"
  spec.email = "brad.ediger@madriska.com"
  spec.rubyforge_project = "prawn-security"
  spec.homepage = "http://github.com/madriska/prawn-security/"
  spec.description = <<END_DESC
  Prawn/Security adds document encryption, password protection, and permissions to Prawn.
END_DESC
end
 
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

