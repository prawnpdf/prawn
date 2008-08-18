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
  
  class File
    def self.read_binary(file) 
      File.open(file,"rb") { |f| f.read } 
    end
  end
  
  def ruby_18
    yield
  end
  
  def ruby_19
    false
  end
     
else
  
  class File
    def self.read_binary(file) 
      File.open(file,"rb:BINARY") { |f| f.read } 
    end
  end  
 
  def ruby_18 
    false  
  end
  
  def ruby_19
    yield
  end 
  
end 
