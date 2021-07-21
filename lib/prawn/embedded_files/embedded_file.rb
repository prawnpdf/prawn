# frozen_string_literal: true

require 'digest/md5'

module Prawn
  module EmbeddedFiles
    class EmbeddedFile
      attr_reader :chksum

      def initialize(data, options = {})
        @creation_date = options[:creation_date]
        unless @creation_date.instance_of?(Time)
          @creation_date = Time.now.utc
        end

        @mod_date = options[:modification_date]
        unless @mod_date.instance_of?(Time)
          @mod_date = Time.now.utc
        end

        @chksum = Digest::MD5.hexdigest(data)
        @data = data.dup
      end

      def build_pdf_object(document)
        obj = document.ref!(
          Type: :EmbeddedFile,
          Params: {
            CreationDate: @creation_date,
            ModDate: @mod_date,
            CheckSum: PDF::Core::LiteralString.new(@chksum),
            Size: @data.length
          }
        )

        obj << @data
        obj.stream.compress!
        obj
      end
    end
  end
end
