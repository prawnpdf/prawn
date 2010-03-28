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

      BASE_OBJECTS = %w[info pages root]

      def initialize(opts = {})
        @objects = {}
        @identifiers = []
        
        # Create required PDF roots
        if opts[:template]
          load_file(opts[:template])
        else
          @info     = ref(opts[:info] || {}).identifier
          pages    = ref(:Type => :Pages, :Count => 0, :Kids => [])
          @root     = ref(:Type => :Catalog, :Pages => pages).identifier
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

      # return the object ID that defines the Nth page, where N is a page
      # number and the first page is 1 (not 0)
      #
      def object_id_for_page(k)
        if k == :last
          page_obj = pages.data[:Kids].last
        elsif k == :first
          page_obj = pages.data[:Kids].first
        else
          page_obj = pages.data[:Kids][k-1]
        end
        page_obj ? page_obj.identifier : nil
      end

      private

      def load_file(filename)
        unless File.file?(filename)
          raise ArgumentError, "#{filename} does not exist"
        end

        unless PDF.const_defined?("Hash")
          raise "PDF::Hash not found. Is PDF::Reader > 0.8?"
        end

        hash = PDF::Hash.new(filename)
        src_info = hash.trailer[:Info]
        src_root = hash.trailer[:Root]

        if src_info
          @info = load_object_graph(hash, src_info).identifier
        else
          @info = ref({}).identifier
        end

        if src_root
          @root = load_object_graph(hash, src_root).identifier
        else
          @pages   = ref(:Type => :Pages, :Count => 0, :Kids => []).identifier
          @root    = ref(:Type => :Catalog, :Pages => @pages).identifier
        end
      rescue PDF::Reader::MalformedPDFError, PDF::Reader::InvalidObjectError
        msg = "Error reading template file. If you are sure it's a valid PDF, it may be a bug."
        raise Prawn::Errors::TemplateError, msg
      rescue PDF::Reader::UnsupportedFeatureError
        msg = "Template file contains unsupported PDF features"
        raise Prawn::Errors::TemplateError, msg
      end

      def load_object_graph(hash, object)
        @loaded_objects ||= {}
        case object
        when Hash then
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
          Prawn::Core::LiteralString.new(object)
        else
          object
        end
      end
    end
  end
end
