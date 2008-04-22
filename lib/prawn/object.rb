require 'stringio'

module Prawn
  class Object
    attr_reader :id, :gen
    attr_accessor :offset, :data, :stream

    def initialize(id, gen)
      @id = id
      @gen = gen
    end

    def to_ref
      "#{id} #{gen} R"
    end

    def to_s
      raise "Object #{id} has no data" if data.nil?
      @output = StringIO.new
      @output << "#{id} #{gen} obj" << Prawn::CRLF
      @output << Prawn::Object.to_pdf(data) << Prawn::CRLF
      if stream
        @output << "stream" << Prawn::CRLF 
        @output << stream
        @output << "endstream" << Prawn::CRLF 
      end
      @output << "endobj" << Prawn::CRLF
      @output.string
    end

    # convert a standard ruby object into its PDF equivilant
    def self.to_pdf(obj)
      case obj
        when Hash then
          ret = "<< "
          obj.each do |key, val|
            ret << "/#{key} #{val}" << Prawn::CRLF
          end
          ret << ">>"
          ret
        else
          raise ArgumentError, "Unable to convert a #{obj.class} into a PDF equivilant"
      end
    end
  end
end
