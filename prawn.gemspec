PRAWN_VERSION = "1.0.0.rc1"

Gem::Specification.new do |spec|
  spec.name = "prawn"
  spec.version = PRAWN_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "A fast and nimble PDF generator for Ruby"
  spec.files =  Dir.glob("{examples,lib,spec,data}/**/**/*") +
    ["Rakefile", "prawn.gemspec", "COPYING", "LICENSE", "GPLv2", "GPLv3"]
  spec.require_path = "lib"
  spec.required_ruby_version = '>= 1.8.7'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.test_files = Dir[ "spec/*_spec.rb" ]
  spec.extra_rdoc_files = %w{README.md LICENSE COPYING GPLv2 GPLv3}
  spec.rdoc_options << '--title' << 'Prawn Documentation' <<
                       '--main'  << 'README.md' << '-q'
  spec.authors = ["Gregory Brown","Brad Ediger","Daniel Nelson","Jonathan Greenberg","James Healy"]
  spec.email = ["gregory.t.brown@gmail.com","brad@bradediger.com","dnelson@bluejade.com","greenberg@entryway.net","jimmy@deefa.com"]
  spec.rubyforge_project = "prawn"
  spec.add_dependency('pdf-reader', '>=0.9.0')
  spec.add_dependency('ttfunk', '~>1.0.3')
  spec.add_development_dependency('pdf-inspector', '~> 1.0.1')
  spec.homepage = "http://prawn.majesticseacreature.com"
  spec.description = <<END_DESC
  Prawn is a fast, tiny, and nimble PDF generator for Ruby
END_DESC
  spec.post_install_message = <<END_DESC

  ********************************************


  A lot has changed recently in Prawn.

  Please read the changelog for details:

  https://github.com/sandal/prawn/wiki/CHANGELOG


  ********************************************

END_DESC
end
