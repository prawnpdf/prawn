# encoding: utf-8

# object_store.rb : Implements PDF object repository for Prawn
#
# Copyright August 2008, Brad Ediger.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  class ObjectStore
    include Enumerable

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

  end
end
