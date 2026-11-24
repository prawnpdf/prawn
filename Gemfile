# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

# Evaluate Gemfile.local if it exists
if File.exist?("#{__FILE__}.local")
  instance_eval(File.read("#{__FILE__}.local"), "#{__FILE__}.local")
end

gem 'pdf-inspector', '>= 1.2.1', '< 2.0.a' unless dependencies.find { |d| d.name == 'pdf-inspector' }
gem 'pdf-reader', '~> 1.4', '>= 1.4.1' unless dependencies.find { |d| d.name == 'pdf-reader' }
gem 'prawn-dev', '~> 0.5.0' unless dependencies.find { |d| d.name == 'prawn-dev' }
gem 'prawn-manual_builder', '~> 0.4.0' unless dependencies.find { |d| d.name == 'prawn-manual_builder' }
