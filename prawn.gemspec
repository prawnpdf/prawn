basedir = File.expand_path(File.dirname(__FILE__))

require "#{basedir}/lib/prawn/version"

Gem::Specification.new do |spec|
  spec.name = "prawn"
  spec.version = Prawn::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "A fast and nimble PDF generator for Ruby"
  spec.files =  Dir.glob("{examples,lib,spec,manual}/**/**/*") +
                Dir.glob("data/{encodings,images,pdfs}/*") +
                Dir.glob("data/fonts/{MustRead.html,*.afm}") +
                ["data/shift_jis_text.txt"] +
                ["Rakefile", "prawn.gemspec", "Gemfile",
                 "COPYING", "LICENSE", "GPLv2", "GPLv3",
                 ".yardopts"]
  spec.require_path = "lib"
  spec.required_ruby_version = '>= 2.0.0'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.test_files = Dir[ "spec/*_spec.rb" ]
  spec.authors = ["Gregory Brown", "Brad Ediger", "Daniel Nelson", "Jonathan Greenberg", "James Healy"]
  spec.email = ["gregory.t.brown@gmail.com", "brad@bradediger.com", "dnelson@bluejade.com", "greenberg@entryway.net", "jimmy@deefa.com"]
  spec.rubyforge_project = "prawn"
  spec.licenses = ['RUBY', 'GPL-2', 'GPL-3']

  spec.add_dependency('ttfunk', '~> 1.4.0')
  spec.add_dependency('pdf-core', "~> 0.6.0")

  spec.add_development_dependency('pdf-inspector', '~> 1.2.0')
  spec.add_development_dependency('yard')
  spec.add_development_dependency('rspec', '2.14.1')
  spec.add_development_dependency('mocha')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('prawn-manual_builder', ">= 0.2.0")
  spec.add_development_dependency('pdf-reader', '~>1.2')
  spec.add_development_dependency('rubocop', '0.30.1')
  spec.add_development_dependency('code_statistics', '0.2.13')

  spec.homepage = "http://prawn.majesticseacreature.com"
  spec.description = <<END_DESC
  Prawn is a fast, tiny, and nimble PDF generator for Ruby
END_DESC
end
