# frozen_string_literal: true

GEMSPEC = File.expand_path('prawn.gemspec', __dir__)
require 'prawn/dev/tasks'

task default: %i[spec rubocop]

desc "Generate the 'Prawn by Example' manual"
task :manual do
  puts 'Building manual...'
  require File.expand_path(File.join(__dir__, %w[manual contents]))
  prawn_manual_document.render_file('manual.pdf')
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
