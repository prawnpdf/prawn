source "https://rubygems.org"

gem "ttfunk", "~>1.0.3"
gem "pdf-reader", "~> 1.2"
gem "ruby-rc4"

platforms :rbx do
  gem "rubysl-singleton", "~> 2.0"
  gem "rubysl-digest", "~> 2.0"
  gem "rubysl-enumerator", "~> 2.0"
end

group :development do
  gem "coderay", "~> 1.0.7"
  gem "rdoc"
end

group :test do
  gem "pdf-inspector", "~> 1.1.0", :require => "pdf/inspector"
  gem "rspec"
  gem "mocha", :require => false
  gem "rake"
end
