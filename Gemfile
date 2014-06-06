source "https://rubygems.org"

gemspec

gem 'ttfunk', git: 'https://github.com/prawnpdf/ttfunk.git',
              ref: '68ae2f2501dcd042793ee49f7c63966d44c47e19'

if ENV["CI"] 
  platforms :rbx do
    gem "rubysl-singleton", "~> 2.0"
    gem "rubysl-digest", "~> 2.0"
    gem "rubysl-enumerator", "~> 2.0"
  end
end
