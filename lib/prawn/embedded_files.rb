# frozen_string_literal: true

module Prawn
  module EmbeddedFiles
    # include PDF::Core::EmbeddedFiles
    # Link to PR (https://github.com/prawnpdf/pdf-core/pull/47)

    def file(src, options = {})
      path = Pathname.new(src)
      mut_opts = options.dup

      if path.directory?
        raise ArgumentError, 'Data source can\'t be a directory'
      elsif path.file?
        data = path.read
        mut_opts[:name] ||= src
        mut_opts[:creation_date] ||= path.birthtime
        mut_opts[:modification_date] ||= path.mtime
      else
        data = src
      end

      @file_registry ||= {}

      file = EmbeddedFile.new(data, mut_opts)
      file_obj = @file_registry[file.checksum]

      if file_obj.nil?
        file_obj = file.build_pdf_object(self)
        @file_registry[file.checksum] = file_obj
      end

      filespec = Filespec.new(file_obj, mut_opts)
      filespec_obj = filespec.build_pdf_object(self)

      unless filespec.hidden?
        # Wait for pdf-core PR

        # attach_file(filespec.file_name, filespec_obj)
      end
    end
  end
end

require_relative 'embedded_files/embedded_file'
require_relative 'embedded_files/filespec'
