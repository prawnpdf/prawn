Gem::Specification.new do |spec|
  spec.name = "prawn"
  spec.version = File.read(File.expand_path('VERSION', File.dirname(__FILE__))).strip
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
  spec.required_ruby_version = '>= 1.9.3'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.test_files = Dir[ "spec/*_spec.rb" ]
  spec.authors = ["Gregory Brown","Brad Ediger","Daniel Nelson","Jonathan Greenberg","James Healy"]
  spec.email = ["gregory.t.brown@gmail.com","brad@bradediger.com","dnelson@bluejade.com","greenberg@entryway.net","jimmy@deefa.com"]
  spec.rubyforge_project = "prawn"
  spec.licenses = ['RUBY', 'GPL-2', 'GPL-3']

  spec.add_dependency('ttfunk', '~> 1.1.1')
  spec.add_dependency('pdf-core', "~> 0.2.4")

  spec.add_development_dependency('pdf-inspector', '~> 1.1.0')
  spec.add_development_dependency('coderay', '~> 1.0.7')
  spec.add_development_dependency('yard')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('mocha')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('pdf-reader', '~>1.2')

  spec.homepage = "http://prawn.majesticseacreature.com"
  spec.description = <<END_DESC
  Prawn is a fast, tiny, and nimble PDF generator for Ruby
END_DESC
  spec.post_install_message = <<END_DESC

  ********************************************


  A lot has changed recently in Prawn.

  Please read the changelog for details:

  https://github.com/prawnpdf/prawn/wiki/CHANGELOG


  ********************************************

END_DESC
end
