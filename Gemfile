source "https://rubygems.org"

gem "pdf-core", :git => "https://github.com/prawnpdf/pdf-core.git",
                :branch => "renderer"
gemspec

if ENV["CI"] 
  platforms :rbx do
    gem "rubysl-singleton", "~> 2.0"
    gem "rubysl-digest", "~> 2.0"
    gem "rubysl-enumerator", "~> 2.0"
  end
end
