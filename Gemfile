source "https://rubygems.org"

gem "pdf-core", :github => "prawnpdf/pdf-core",
                :branch => "decimal-rounding"
gemspec

if ENV["CI"] 
  platforms :rbx do
    gem "rubysl-singleton", "~> 2.0"
    gem "rubysl-digest", "~> 2.0"
    gem "rubysl-enumerator", "~> 2.0"
  end
end
