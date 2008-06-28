# encoding: utf-8

if RUBY_VERSION < "1.9"  
  class String
    alias_method :lines, :to_a
  end
end 
