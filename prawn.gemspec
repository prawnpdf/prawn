# frozen_string_literal: true

basedir = __dir__

require "#{basedir}/lib/prawn/version"

Gem::Specification.new do |spec|
  spec.name = 'prawn'
  spec.version = Prawn::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = 'A fast and nimble PDF generator for Ruby'
  spec.description = 'Prawn is a fast, tiny, and nimble PDF generator for Ruby'

  spec.files = Dir.glob('{lib}/**/**/*') +
    Dir.glob('data/fonts/{MustRead.html,*.afm}') +
    %w[COPYING LICENSE GPLv2 GPLv3]

  if File.basename($PROGRAM_NAME) == 'gem' && ARGV.include?('build')
    signing_key = File.expand_path('~/.gem/gem-private_key.pem')
    if File.exist?(signing_key)
      spec.cert_chain = ['certs/pointlessone.pem']
      spec.signing_key = signing_key
    else
      warn 'WARNING: Signing key is missing. The gem is not signed and its authenticity can not be verified.'
    end
  end

  spec.required_ruby_version = '>= 2.7'
  spec.required_rubygems_version = '>= 1.3.6'

  spec.authors = [
    'Alexander Mankuta', 'Gregory Brown', 'Brad Ediger', 'Daniel Nelson',
    'Jonathan Greenberg', 'James Healy',
  ]
  spec.email = [
    'alex@pointless.one', 'gregory.t.brown@gmail.com', 'brad@bradediger.com',
    'dnelson@bluejade.com', 'greenberg@entryway.net', 'jimmy@deefa.com',
  ]
  spec.licenses = %w[Nonstandard GPL-2.0-only GPL-3.0-only]
  spec.homepage = 'http://prawnpdf.org/'
  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'homepage_uri' => spec.homepage,
    'changelog_uri' => "https://github.com/prawnpdf/prawn/blob/#{spec.version}/CHANGELOG.md",
    'source_code_uri' => 'https://github.com/prawnpdf/prawn',
    'documentation_uri' => "https://prawnpdf.org/docs/prawn/#{spec.version}/",
    'bug_tracker_uri' => 'https://github.com/prawnpdf/prawn/issues',
  }

  spec.add_dependency('matrix', '~> 0.4')
  spec.add_dependency('pdf-core', '~> 0.9.0')
  spec.add_dependency('ttfunk', '~> 1.7')

  spec.add_development_dependency('pdf-inspector', '>= 1.2.1', '< 2.0.a')
  spec.add_development_dependency('pdf-reader', '~> 1.4', '>= 1.4.1')
  spec.add_development_dependency('prawn-dev', '~> 0.4.0')
  spec.add_development_dependency('prawn-manual_builder', '~> 0.4.0')
end
