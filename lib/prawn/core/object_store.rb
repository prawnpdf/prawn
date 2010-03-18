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

      attr_reader :info, :root

      def initialize(info={})
        @objects = {}
        @identifiers = []
        
        # Create required PDF roots
        if info[:template]
          load_file(info[:template])
        else
          @info     = ref(info).identifier
          @pages    = ref(:Type => :Pages, :Count => 0, :Kids => []).identifier
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
      end

      def load_object_graph(hash, object)
        @loaded_objects ||= {}
        @stream_data ||= {}
        case object
        when Hash then
          object.each { |key,value| object[key] = load_object_graph(hash, value) }
          object
        when Array then
          object.map { |item| load_object_graph(hash, item)}
        when PDF::Reader::Stream then
          stream_dict = load_object_graph(hash, object.hash)
          new_obj = ref(stream_dict)
          new_obj << object.data
          new_obj
        when PDF::Reader::Reference then
          unless @loaded_objects.has_key?(object.id)
            @loaded_objects[object.id] = ref(nil)
            new_obj = load_object_graph(hash, hash[object.id])
            if new_obj.kind_of?(Prawn::Core::Reference)
              @loaded_objects[object.id] = new_obj
            else
              @loaded_objects[object.id].data = new_obj
            end
          end
          @loaded_objects[object.id]
        when String
          Prawn::Core::LiteralString.new(object)
        else
          object
        end
      end
    end
  end
end
