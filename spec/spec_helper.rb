# frozen_string_literal: true

puts "Prawn specs: Running on Ruby Version: #{RUBY_VERSION}"

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require_relative '../lib/prawn'

Prawn.debug = true
Prawn::Fonts::AFM.hide_m17n_warning = true

# prawn-manual_builder uses URI::RFC2396_PARSER, a constant only present in
# the `uri` gem >= 1.0. Ruby ships different bundled versions of `uri` as a
# default gem across releases, and some are older than that. Forcing a newer
# `uri` via the Gemfile isn't an option: on Rubies old enough to need it, only
# an equally old Bundler is installable, and that Bundler can't safely
# replace an already-activated default gem. Define the constant ourselves
# instead: on those old `uri` versions, URI::DEFAULT_PARSER already *is* the
# RFC2396 parser (the switch to RFC3986 happened in uri 1.0 alongside the
# introduction of URI::RFC2396_PARSER as an explicit escape hatch), so this
# is equivalent, not just a stand-in.
require 'uri'
URI::RFC2396_PARSER = URI::DEFAULT_PARSER unless defined?(URI::RFC2396_PARSER)

require 'rspec'
require 'pdf/reader'
require 'pdf/inspector'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/extensions/ and its subdirectories.
Dir[File.join(__dir__, 'extensions', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.include(EncodingHelpers)
end

# Create a document.
def create_pdf(klass = Prawn::Document, &block)
  klass.new(margin: 0, &block)
end

RSpec::Matchers.define(:have_parseable_xobjects) do
  match do |actual|
    expect { PDF::Inspector::XObject.analyze(actual.render) }.to_not raise_error
    true
  end
  failure_message do |actual|
    "expected that #{actual}'s XObjects could be successfully parsed"
  end
end

# Make some methods public to assist in testing
# module Prawn
#   module Graphics
#     public :map_to_absolute
#   end
# end
