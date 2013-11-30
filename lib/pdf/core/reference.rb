# encoding: utf-8

# reference.rb : Implementation of PDF indirect objects
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.


module PDF
  module Core
    class Reference #:nodoc:

      attr_accessor :gen, :data, :offset, :stream, :live, :identifier

      def initialize(id, data)
        @identifier = id
        @gen        = 0
        @data       = data
        @stream     = Stream.new
      end

      def object
        output = "#{@identifier} #{gen} obj\n"
        unless @stream.empty?
          output << PDF::Core::PdfObject(data.merge @stream.data) << "\n" << @stream.object
        else
          output << PDF::Core::PdfObject(data) << "\n"
        end

        output << "endobj\n"
      end

      def <<(io)
        raise "Cannot attach stream to non-dictionary object" unless @data.is_a?(::Hash)
        (@stream ||= Stream.new) << io
      end

      def to_s
        "#{@identifier} #{gen} R"
      end

      # Creates a deep copy of this ref. If +share+ is provided, shares the
      # given dictionary entries between the old ref and the new.
      #
      def deep_copy(share=[])
        r = dup

        case r.data
        when ::Hash
          # Copy each entry not in +share+.
          (r.data.keys - share).each do |k|
            r.data[k] = Marshal.load(Marshal.dump(r.data[k]))
          end
        when PDF::Core::NameTree::Node
          r.data = r.data.deep_copy
        else
          r.data = Marshal.load(Marshal.dump(r.data))
        end

        r.stream = Marshal.load(Marshal.dump(r.stream))
        r
      end

      # Replaces the data and stream with that of other_ref.
      def replace(other_ref)
        @data   = other_ref.data
        @stream = other_ref.stream
      end

      # Marks this and all referenced objects live, recursively.
      def mark_live
        return if defined?(@live) && @live
        @live = true
        referenced_objects.each { |o| o.mark_live }
      end

      private

      # All objects referenced by this one. Used for GC.
      def referenced_objects(obj=@data)
        case obj
        when self.class
          []
        when ::Hash
          obj.values.map{|v| [v] + referenced_objects(v) }
        when Array
          obj.map{|v| [v] + referenced_objects(v) }
        when PDF::Core::OutlineRoot, PDF::Core::OutlineItem
          referenced_objects(obj.to_hash)
        else []
        end.flatten.grep(self.class)
      end

    end

    module_function

    def Reference(*args, &block) #:nodoc:
      Reference.new(*args, &block)
    end
  end
end
