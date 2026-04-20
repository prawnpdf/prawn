# frozen_string_literal: true

module Prawn
  module EmbeddedFiles
    # include PDF::Core::EmbeddedFiles
    # Link to PR (https://github.com/prawnpdf/pdf-core/pull/47)

    # Add the file's data from a source to the document. Any kind of data with
    # a string representation can be embedded.
    #
    # Arguments:
    # <tt>src</tt>:: path to file, string or an object that responds to #to_str
    # and #length.
    #
    # Options:
    # <tt>:name</tt>:: explicit default filename override.
    # <tt>:creation_date</tt>:: date when the file was created.
    # <tt>:modification_date</tt>::  date when the file was last modified.
    # <tt>:description</tt>:: file description.
    # <tt>:hidden</tt>:: if true, prevents the file from appearing in the
    # catalog. (default false)
    #
    #   Prawn::Document.generate("file1.pdf") do
    #     dice = "#{Prawn::DATADIR}/images/dice.png"
    #     file dice, description: 'Example of an embedded image file'
    #   end
    #
    # This method returns an instance of PDF::Core::NameTree::Value
    # corresponding to the file in the embedded files catalog entry node. If
    # hidden, then nil is returned.
    #
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

      file = EmbeddedFile.new(data, mut_opts)
      file_obj = file_registry[file.checksum]

      if file_obj.nil?
        file_obj = file.build_pdf_object(self)
        file_registry[file.checksum] = file_obj
      end

      filespec = Filespec.new(file_obj, mut_opts)
      filespec_obj = filespec.build_pdf_object(self)

      unless filespec.hidden?
        # Wait for pdf-core PR

        # attach_file(filespec.file_name, filespec_obj)
      end
    end

    private

    def file_registry
      @file_registry ||= {}
    end
  end
end

require_relative 'embedded_files/embedded_file'
require_relative 'embedded_files/filespec'
