require "rubygems"
require "pdf/reader"
require "pdf/inspector/text" 
require "pdf/inspector/xobject"
require "pdf/inspector/extgstate"
require "pdf/inspector/graphics"
require "pdf/inspector/page"

module PDF
  class Inspector
    def self.analyze(output,*args,&block) 
      obs = self.new(*args, &block)
      PDF::Reader.string(output,obs)
      obs  
    end         
    
    def self.analyze_file(filename,*args,&block)
      analyze(File.open(filename, "rb") { |f| f.read },*args,&block)
    end  
    
    def self.parse(obj)
      PDF::Reader::Parser.new(
        PDF::Reader::Buffer.new(StringIO.new(obj)), nil).parse_token
    end
  end
end
