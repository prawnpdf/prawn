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
        @output << stream.string
        @output << "endstream" << Prawn::CRLF 
      end
      @output << "endobj" << Prawn::CRLF
      @output.string
    end

    # convert a standard ruby object into its PDF equivilant
    def self.to_pdf(obj)
      case obj
        when Array then
          obj.collect! {|i| self.to_pdf(i)}
          "[ #{obj.join(" ")} ]"
        when Hash then
          ret = "<< " << Prawn::CRLF
          obj.each do |key, val|
            ret << "  #{self.to_pdf(key)} #{self.to_pdf(val)}" << Prawn::CRLF
          end
          ret << ">>"
          ret
        when Numeric then
          obj.to_s
        when Prawn::Name then
          obj.to_s
        when Prawn::Object then
          obj.to_ref
        when String then
          "(#{obj})"
        else
          raise ArgumentError, "Unable to convert a #{obj.class} into a PDF equivilant (#{obj.inspect})"
      end
    end
  end
end
