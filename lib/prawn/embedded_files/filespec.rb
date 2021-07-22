# frozen_string_literal: true

module Prawn
  module EmbeddedFiles
    class Filespec
      attr_reader :file_name

      def initialize(file, options = {})
        name = options[:name] || file.checksum

        @file_name = PDF::Core::LiteralString.new(name)

        if options[:description]
          desc_str = options[:description].to_s
          @description = PDF::Core::LiteralString.new(desc_str)
        end

        @hidden = options[:hidden]
        @file = file
      end

      def hidden?
        @hidden
      end

      def build_pdf_object(document)
        obj = document.ref!(
          Type: :Filespec,
          F: @file_name,
          EF: { F: @file },
          UF: @file_name
        )

        obj.data[:Desc] = @description if @description
        obj
      end
    end
  end
end
