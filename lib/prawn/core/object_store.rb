# encoding: utf-8

# prawn/core/object_store.rb : Implements PDF object repository for Prawn
#
# Copyright August 2009, Brad Ediger.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.


require 'pdf/reader'

module Prawn
  module Core
    class ObjectStore #:nodoc:
      include Enumerable

      attr_reader :min_version

      BASE_OBJECTS = %w[info pages root]

      def initialize(opts = {})
        @objects = {}
        @identifiers = []

        load_file(opts[:template]) if opts[:template]

        @info  ||= ref(opts[:info] || {}).identifier
        @root  ||= ref(:Type => :Catalog).identifier
        if pages.nil?
          root.data[:Pages] = ref(:Type => :Pages, :Count => 0, :Kids => [])
        end
      end

      def ref(data, &block)
        push(size + 1, data, &block)
      end

      def info
        @objects[@info]
      end

      def root
        @objects[@root]
      end

      def pages
        root.data[:Pages]
      end

      def page_count
        pages.data[:Count]
      end

      # Adds the given reference to the store and returns the reference object.
      # If the object provided is not a Prawn::Core::Reference, one is created from the
      # arguments provided.
      #
      def push(*args, &block)
        reference = if args.first.is_a?(Prawn::Core::Reference)
          args.first
        else
          Prawn::Core::Reference.new(*args, &block)
        end

        @objects[reference.identifier] = reference
        @identifiers << reference.identifier
        reference
      end

      alias_method :<<, :push

      def each
        @identifiers.each do |id|
          yield @objects[id]
        end
      end

      def [](id)
        @objects[id]
      end

      def size
        @identifiers.size
      end
      alias_method :length, :size

      def compact
        # Clear live markers
        each { |o| o.live = false }

        # Recursively mark reachable objects live, starting from the roots
        # (the only objects referenced in the trailer)
        root.mark_live
        info.mark_live

        # Renumber live objects to eliminate gaps (shrink the xref table)
        if @objects.any?{ |_, o| !o.live }
          new_id = 1
          new_objects = {}
          new_identifiers = []

          each do |obj|
            if obj.live
              obj.identifier = new_id
              new_objects[new_id] = obj
              new_identifiers << new_id
              new_id += 1
            end
          end

          @objects = new_objects
          @identifiers = new_identifiers
        end
      end

      # returns the object ID for a particular page in the document. Pages
      # are indexed starting at 1 (not 0!).
      #
      #   object_id_for_page(1)
      #   => 5
      #   object_id_for_page(10)
      #   => 87
      #   object_id_for_page(-11)
      #   => 17
      #
      def object_id_for_page(k)
        k -= 1 if k > 0
        flat_page_ids = get_page_objects(pages).flatten
        flat_page_ids[k]
      end

      # imports all objects required to render a page from another PDF. The
      # objects are added to the current object store, but NOT linked
      # anywhere.
      #
      # The object ID of the root Page object is returned, it's up to the
      # calling code to link that into the document structure somewhere. If
      # this isn't done the imported objects will just be removed when the
      # store is compacted.
      #
      # Imports nothing and returns nil if the requested page number doesn't
      # exist. page_num is 1 indexed, so 1 indicates the first page.
      #
      def import_page(filename, page_num)
        @loaded_objects = {}
        unless File.file?(filename)
          raise ArgumentError, "#{filename} does not exist"
        end

        hash = PDF::Reader::ObjectHash.new(filename)
        ref  = hash.page_references[page_num - 1]

        ref.nil? ? nil : load_object_graph(hash, ref).identifier

      rescue PDF::Reader::MalformedPDFError, PDF::Reader::InvalidObjectError
        msg = "Error reading template file. If you are sure it's a valid PDF, it may be a bug."
        raise Prawn::Errors::TemplateError, msg
      rescue PDF::Reader::UnsupportedFeatureError
        msg = "Template file contains unsupported PDF features"
        raise Prawn::Errors::TemplateError, msg
      end

      private

      # returns a nested array of object IDs for all pages in this object store.
      #
      def get_page_objects(obj)
        if obj.data[:Type] == :Page
          obj.identifier
        elsif obj.data[:Type] == :Pages
          obj.data[:Kids].map { |kid| get_page_objects(kid) }
        end
      end

      # takes a source PDF and uses it as a template for this document.
      #
      def load_file(template)
        unless (template.respond_to?(:seek) && template.respond_to?(:read)) ||
               File.file?(template)
          raise ArgumentError, "#{template} does not exist"
        end

        hash = PDF::Reader::ObjectHash.new(template)
        src_info = hash.trailer[:Info]
        src_root = hash.trailer[:Root]
        @min_version = hash.pdf_version.to_f

        if hash.trailer[:Encrypt]
          msg = "Template file is an encrypted PDF, it can't be used as a template"
          raise Prawn::Errors::TemplateError, msg
        end

        if src_info
          @info = load_object_graph(hash, src_info).identifier
        end

        if src_root
          @root = load_object_graph(hash, src_root).identifier
        end
      rescue PDF::Reader::MalformedPDFError, PDF::Reader::InvalidObjectError
        msg = "Error reading template file. If you are sure it's a valid PDF, it may be a bug."
        raise Prawn::Errors::TemplateError, msg
      rescue PDF::Reader::UnsupportedFeatureError
        msg = "Template file contains unsupported PDF features"
        raise Prawn::Errors::TemplateError, msg
      end

      # recurse down an object graph from a source PDF, importing all the
      # indirect objects we find.
      #
      # hash is the PDF::Reader::ObjectHash to extract objects from, object is
      # the object to extract.
      #
      def load_object_graph(hash, object)
        @loaded_objects ||= {}
        case object
        when ::Hash then
          object.each { |key,value| object[key] = load_object_graph(hash, value) }
          object
        when Array then
          object.map { |item| load_object_graph(hash, item)}
        when PDF::Reader::Reference then
          unless @loaded_objects.has_key?(object.id)
            @loaded_objects[object.id] = ref(nil)
            new_obj = load_object_graph(hash, hash[object])
          if new_obj.kind_of?(PDF::Reader::Stream)
            stream_dict = load_object_graph(hash, new_obj.hash)
            @loaded_objects[object.id].data = stream_dict
            @loaded_objects[object.id] << new_obj.data
            else
              @loaded_objects[object.id].data = new_obj
            end
          end
          @loaded_objects[object.id]
        when PDF::Reader::Stream
          # Stream is a subclass of string, so this is here to prevent the stream
          # being wrapped in a LiteralString
          object
        when String
          is_utf8?(object) ? object : Prawn::Core::ByteString.new(object)
        else
          object
        end
      end

      ruby_18 do
        def is_utf8?(str)
          begin
            str.unpack("U*")
            true
          rescue
            false
          end
        end
      end
      ruby_19 do
        def is_utf8?(str)
          str.force_encoding("utf-8")
          str.valid_encoding?
        end
      end
    end
  end
end
