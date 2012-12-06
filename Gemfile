source :rubygems

gem "ttfunk", "~>1.0.3"
gem "pdf-reader", "~> 1.2"

group :development do
  gem "coderay", "~> 1.0.7"

  # require the rdoc gem for building docs, but only on MRI. On Jruby this
  # pulls in a json dependency that bundler fails to resolve
  gem "rdoc", :platforms => [:ruby_19]
end

group :test do
  gem "pdf-inspector", "~> 1.0.2", :require => "pdf/inspector"
  gem "rspec"
  gem "mocha", :require => false
  gem "rake"
end
