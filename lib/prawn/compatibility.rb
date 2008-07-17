# encoding: utf-8

if RUBY_VERSION < "1.9"
  require "strscan"
  
  class String
    alias_method :lines, :to_a
    
    def each_char
      scanner, char = StringScanner.new(self), /./mu
      loop { yield(scanner.scan(char) || break) }
    end
  end
end 
