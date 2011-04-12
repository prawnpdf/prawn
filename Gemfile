source :rubygems

gem "ttfunk", "~>1.0.0"
gem "pdf-reader", "~>0.9.0"

group :test do
  # TODO: once an official pdf-inspector gem is released, remove the :git
  #       option from the following line
  gem "pdf-inspector", "~>1.0.0", :require => "pdf/inspector", :git => "https://github.com/sandal/pdf-inspector.git"
  gem "test-spec"
  gem "mocha"
  gem "test-unit", "1.2.3", :platforms => [:ruby_19, :mingw_19]
  gem "rake"
end
