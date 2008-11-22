module Prawn
  class Document
    module Annotations
      # Adds a new annotation (section 8.4 in PDF spec) to the current page.
      # +options+ must be a Hash describing the annotation.
      def annotate(options)
        @current_page.data[:Annots] ||= []
        options = options.merge(:Type => :Annot)
        @current_page.data[:Annots] << ref(options)
        return options
      end

      # A convenience method for creating Text annotations. +rect+ must be an array
      # of four numbers, describing the bounds of the annotation. +contents+ should
      # be a string, to be shown when the annotation is activated.
      def text_annotation(rect, contents, options={})
        options = options.merge(:Subtype => :Text, :Rect => rect, :Contents => contents)
        annotate(options)
      end

      # A convenience method for creating Link annotations. +rect+ must be an array
      # of four numbers, describing the bounds of the annotation. The +options+ hash
      # should include either :Dest (describing the target destination, usually as a
      # string that has been recorded in the document's Dests tree), or :A (describing
      # an action to perform on clicking the link), or :PA (for describing a URL to
      # link to).
      def link_annotation(rect, options={})
        options = options.merge(:Subtype => :Link, :Rect => rect)
        annotate(options)
      end
    end
  end
end
