# coding: utf-8
#
# Compatibility layer to smooth over differences between Ruby implementations
# The oldest version of Ruby which is supported is MRI 1.8.7
# Ideally, all version-specific or implementation-specific code should be
#   kept in this file (but that ideal has not been attained yet)

class String  #:nodoc:
  def first_line
    self.each_line { |line| return line }
  end

  unless "".respond_to?(:codepoints)
    def codepoints(&block)
      if block_given?
        unpack("U*").each(&block)
      else
        unpack("U*")
      end
    end
  end

  if "".respond_to?(:encode)
    def normalize_to_utf8
      begin
        encode(Encoding::UTF_8)
      rescue
        raise Prawn::Errors::IncompatibleStringEncoding, "Encoding " +
        "#{text.encoding} can not be transparently converted to UTF-8. " +
        "Please ensure the encoding of the string you are attempting " +
        "to use is set correctly"
      end      
    end
    alias :unicode_characters :each_char
    alias :unicode_length     :length

  else
    def normalize_to_utf8
      begin
        # use unpack as a hackish way to verify the string is valid utf-8
        unpack("U*")
        return dup
      rescue
        raise Prawn::Errors::IncompatibleStringEncoding, "The string you " +
        "are attempting to render is not encoded in valid UTF-8."
      end
    end
    def unicode_characters
      if block_given?
        unpack("U*").each { |c| yield [c].pack("U") }
      else
        unpack("U*").map { |c| [c].pack("U") }
      end
    end
    def unicode_length
      unpack("U*").length
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
