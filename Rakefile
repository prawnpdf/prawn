# frozen_string_literal: true

GEMSPEC = File.expand_path('prawn.gemspec', __dir__)
require 'prawn/dev/tasks'

task default: %i[spec rubocop]

desc "Generate the 'Prawn by Example' manual"
task :manual do
  puts 'Building manual...'
  require_relative 'manual/manual'
  manual_path = File.expand_path('manual/manual.rb', __dir__)
  manual = eval(File.read(manual_path), TOPLEVEL_BINDING, manual_path) # rubocop:disable Security/Eval
  manual.generate('manual.pdf')
  puts 'The Prawn manual is available at manual.pdf. Happy Prawning!'
end

desc 'Run a console with Prawn loaded'
task :console do
  require 'irb'
  require 'irb/completion'
  require_relative 'lib/prawn'
  Prawn.debug = true

  ARGV.clear
  IRB.start
end
