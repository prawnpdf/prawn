# coding: utf-8
#
# Why would we ever use Ruby 1.8.7 when we can backport with something
# as simple as this?
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
class String  #:nodoc:
  def first_line
    self.each_line { |line| return line }
  end
  unless "".respond_to?(:lines)
    alias_method :lines, :to_a
  end
  unless "".respond_to?(:each_char)
    def each_char #:nodoc:
      # copied from jcode
      if block_given?
        scan(/./m) { |x| yield x }
      else
        scan(/./m)
      end
    end
  end
end

unless File.respond_to?(:binread) 
  def File.binread(file) #:nodoc:
    File.open(file,"rb") { |f| f.read } 
  end
end

if RUBY_VERSION < "1.9"
  
  def ruby_18  #:nodoc:  
    yield
  end
  
  def ruby_19  #:nodoc:  
    false
  end
     
else  
 
  def ruby_18  #:nodoc:  
    false  
  end
  
  def ruby_19  #:nodoc:  
    yield
  end 
  
end 
