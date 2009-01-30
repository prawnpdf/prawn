# This is to be used to generate the prawn meta-gem only.  You probably want to
# build prawn-core unless you know exactly what you are doing, so do rake gem
# instead.

Gem::Specification.new do |spec|
  spec.name = "prawn"
  spec.version = "0.4.99"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "A fast and nimble PDF generator for Ruby"
  spec.add_dependency('prawn-core', '>= 0.4.99')
  spec.add_dependency('prawn-layout')
  spec.add_dependency('prawn-format')
  spec.author = "Gregory Brown"
  spec.email = "  gregory.t.brown@gmail.com"
  spec.rubyforge_project = "prawn"
  spec.homepage = "http://prawn.majesticseacreature.com"
  spec.description = "Prawn is a fast, tiny, and nimble PDF generator for Ruby"
end
