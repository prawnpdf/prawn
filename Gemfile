source "https://rubygems.org"

gemspec

if ENV["CI"]
  platforms :rbx do
    gem "rubysl-singleton", "~> 2.0"
    gem "rubysl-digest", "~> 2.0"
    gem "rubysl-enumerator", "~> 2.0"
  end
end
