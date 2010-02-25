# encoding: utf-8

# prawn/core/object_store.rb : Implements PDF object repository for Prawn
#
# Copyright August 2009, Brad Ediger.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Core
    class ObjectStore #:nodoc:

      include Enumerable

      BASE_OBJECTS = %w[info pages root]

      def initialize(info={})
        @objects = {}
        @identifiers = []
        
        # Create required PDF roots
        @info    = ref(info).identifier
        @pages   = ref(:Type => :Pages, :Count => 0, :Kids => []).identifier
        @root    = ref(:Type => :Catalog, :Pages => pages).identifier
      end
   
      def ref(data, &block)
        push(size + 1, data, &block)
      end                                               

      %w[info pages root].each do |name|
        define_method(name) do
          @objects[instance_variable_get("@#{name}")]
        end
      end

      # Adds the given reference to the store and returns the reference object.
      # If the object provided is not a Prawn::Reference, one is created from the
      # arguments provided.
      #
      def push(*args, &block)
        reference = if args.first.is_a?(Prawn::Reference)
                args.first
              else
                Prawn::Reference.new(*args, &block)
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
    end
  end
end
