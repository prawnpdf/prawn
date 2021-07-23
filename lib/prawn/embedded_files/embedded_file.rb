# frozen_string_literal: true

require 'digest'

module Prawn
  module EmbeddedFiles
    class EmbeddedFile
      attr_reader :checksum

      def initialize(data, options = {})
        @creation_date = options[:creation_date]
        unless @creation_date.kind_of?(Time)
          @creation_date = Time.now.utc
        end

        @modification_date = options[:modification_date]
        unless @modification_date.kind_of?(Time)
          @modification_date = Time.now.utc
        end

        @checksum = Digest::MD5.digest(data)
        @data = data
      end

      def build_pdf_object(document)
        obj = document.ref!(
          Type: :EmbeddedFile,
          Params: {
            CreationDate: creation_date,
            ModDate: modification_date,
            CheckSum: PDF::Core::LiteralString.new(checksum),
            Size: data.length
          }
        )

        obj << data
        obj.stream.compress! if document.compression_enabled?
        obj
      end

      private

      attr_reader :data, :creation_date, :modification_date
    end
  end
end
