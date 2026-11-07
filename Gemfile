# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

# prawn-manual_builder 0.5.0 uses URI::RFC2396_PARSER, which the uri shipped
# with Ruby 2.7 and 3.0 doesn't have.
gem 'uri', '>= 0.13.1'

# Evaluate Gemfile.local if it exists
if File.exist?("#{__FILE__}.local")
  instance_eval(File.read("#{__FILE__}.local"), "#{__FILE__}.local")
end
