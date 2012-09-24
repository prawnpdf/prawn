require 'rubygems'
require 'bundler'
Bundler.setup

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'  

task :default => [:test]
       
desc "Run all tests (test-spec, mocha, and pdf-reader required)"
Rake::TestTask.new do |test|
  # test.ruby_opts  << "-w"  # .should == true triggers a lot of warnings
  test.libs       << "spec"
  test.test_files =  Dir[ "spec/*_spec.rb" ]
  test.verbose    =  true
end

desc "Show code statistics"
task :stats do
  require 'code_statistics'
  CodeStatistics::TEST_TYPES << "Specs"	
  CodeStatistics.new( ["Prawn", "lib"], 
                      ["Specs", "spec"] ).to_s
end

desc "Generate documentation"
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

desc "Run all tests on all supported VMs (rvm required)"
task :test_all_vms do
  supported = %w{ruby-1.9.3-p194
                 ruby-1.9.2-p320
                 ruby-1.8.7-p370
                 jruby-1.6.7.2
                 rbx-1.2.4
                 ree-1.8.7}

  unless `rvm version` =~ /rvm \d+\.\d+/
    puts "\nPlease ensure that rvm is correctly installed and try again."
    exit
  end
  
  installed = `rvm list`
  unless (to_install = supported.reject { |vm| installed.match(vm) }).empty?
    puts "\nPlease install the following Ruby implementation#{'s' unless to_install.one?} (using rvm) and try again:"
    puts to_install.map { |vm| "  #{vm}" }
    exit
  end

  # So you dropped big $$$ on an expensive dev machine with tons of CPU cores?
  # Let's put those cores to work...
  puts "Starting tests..."
  start = Time.now
  pids = supported.map do |vm|
    # fork off a different process for each VM we want to test under
    fork do
      result = `rvm #{vm} do rake 2>/dev/null`

      if result !~ /^Started$/
        puts "** Couldn't run \"test rake\" under #{vm}!"
      elsif result =~ /Command failed with status/
        puts "** \"test rake\" failed under #{vm}!"
        puts "   (saving results to #{vm}-test-output.txt)"
        File.open("#{vm}-test-output.txt", "w") { |f| f.write(result) }
      else
        failures = result[/(\d+) failures/, 1]
        errors   = result[/(\d+) errors/,   1]
        if failures.nil? || errors.nil?
          puts "** Couldn't parse test results under #{vm}"
          puts "   (saving results to #{vm}-test-output.txt)"
          File.open("#{vm}-test-output.txt", "w") { |f| f.write(result) }
        elsif failures == "0" && errors == "0"
          puts "** Passed under #{vm}"
        else
          puts "** FAILED under #{vm}, #{failures} failures, #{errors} errors"
          puts "   (saving results to #{vm}-test-output.txt)"
          File.open("#{vm}-test-output.txt", "w") { |f| f.write(result) }
        end
      end
    end
  end

  pids.each { |pid| Process.wait(pid) }
  puts "Finished in #{Time.now - start} seconds"
end