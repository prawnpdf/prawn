# coding: utf-8
#
# Why would we ever use Ruby 1.8.7 when we can backport with something
# as simple as this?
#
class String  #:nodoc:
  unless "".respond_to?(:lines)
    alias_method :lines, :to_a
  end
end

unless File.respond_to?(:binread)
  def File.binread(file) 
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
