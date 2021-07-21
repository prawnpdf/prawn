# frozen_string_literal: true

module Prawn
  module EmbeddedFiles
    # include PDF::Core::EmbeddedFiles
    # Link to PR (https://github.com/prawnpdf/pdf-core/pull/47)

    def file(src, options = {})
      path = Pathname.new(src)

      if path.directory?
        raise ArgumentError, 'Data source can\'t be a directory'
      elsif path.file?
        data = path.read
        options[:name] ||= src
      else
        data = src
      end

      @file_registry ||= {}

      file = EmbeddedFile.new(data, options)
      file_obj = @file_registry[file.chksum]

      if file_obj.nil?
        file_obj = file.build_pdf_object(self)
        @file_registry[file.chksum] = file_obj
      end

      filespec = Filespec.new(file_obj, options)
      filespec_obj = filespec.build_pdf_object(self)

      unless filespec.hidden
        # Wait for pdf-core PR

        # attach_file(filespec.file_name, filespec_obj)
      end
    end
  end
end

require_relative 'embedded_files/embedded_file'
require_relative 'embedded_files/filespec'
