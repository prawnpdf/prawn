warn "Templates are no longer supported in Prawn!\n" +
     "This code is for experimental testing only, and\n" +
     "will be extracted into its own gem in a future Prawn release"

module Prawn
  # @private
  module Templates
    def initialize_first_page(options)
      return super unless options[:template]

      fresh_content_streams(options)
      go_to_page(1)
    end
   
    ## FIXME: This is going to be terribly brittle because
    # it copy-pastes the start_new_page method. But at least
    # it should only run when templates are used.

    def start_new_page(options = {})
      return super unless options[:template]

      if last_page = state.page
        last_page_size    = last_page.size
        last_page_layout  = last_page.layout
        last_page_margins = last_page.margins
      end

      page_options = {:size => options[:size] || last_page_size,
                      :layout  => options[:layout] || last_page_layout,
                      :margins => last_page_margins}
      if last_page
        new_graphic_state = last_page.graphic_state.dup  if last_page.graphic_state
        #erase the color space so that it gets reset on new page for fussy pdf-readers
        new_graphic_state.color_space = {} if new_graphic_state
        page_options.merge!(:graphic_state => new_graphic_state)
      end

      merge_template_options(page_options, options)

      state.page = PDF::Core::Page.new(self, page_options)

      apply_margin_options(options)
      generate_margin_box

      # Reset the bounding box if the new page has different size or layout
      if last_page && (last_page.size != state.page.size ||
                       last_page.layout != state.page.layout)
        @bounding_box = @margin_box
      end

      state.page.new_content_stream
      use_graphic_settings(true)
      forget_text_rendering_mode!

      unless options[:orphan]
        state.insert_page(state.page, @page_number)
        @page_number += 1

        canvas { image(@background, :scale => @background_scale, :at => bounds.top_left) } if @background
        @y = @bounding_box.absolute_top

        float do
          state.on_page_create_action(self)
        end
      end
    end

    def merge_template_options(page_options, options)
      object_id = state.store.import_page(options[:template], options[:template_page] || 1)
      page_options.merge!(:object_id => object_id, :page_template => true)
    end

    module ObjectStoreExtensions
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
      def import_page(input, page_num)
        @loaded_objects = {}
        if template_id = indexed_template(input, page_num)
          return template_id
        end

        io = if input.respond_to?(:seek) && input.respond_to?(:read)
               input
             elsif File.file?(input.to_s)
               StringIO.new(File.binread(input.to_s))
             else
               raise ArgumentError, "input must be an IO-like object or a filename"
             end

                # unless File.file?(filename)
        #   raise ArgumentError, "#{filename} does not exist"
        # end

        hash = indexed_hash(input, io)
        ref  = hash.page_references[page_num - 1]

        if ref.nil?
          nil
        else
          index_template(input, page_num, load_object_graph(hash, ref).identifier)
        end

      rescue PDF::Reader::MalformedPDFError, PDF::Reader::InvalidObjectError => e
        msg = "Error reading template file. If you are sure it's a valid PDF, it may be a bug.\n#{e.message}"
        raise PDF::Core::Errors::TemplateError, msg
      rescue PDF::Reader::UnsupportedFeatureError
        msg = "Template file contains unsupported PDF features"
        raise PDF::Core::Errors::TemplateError, msg
      end

      private

      # An index for page templates so that their loaded object graph
      # can be reused without multiple loading
      def template_index
        @template_index ||= {}
      end

      # returns the indexed object graph identifier for a template page if
      # it exists
      def indexed_template(input, page_number)
        key = indexing_key(input)
        template_index[key] && template_index[key][page_number]
      end

      # indexes the identifier for a page from a template
      def index_template(input, page_number, id)
        (template_index[indexing_key(input)] ||= {})[page_number] ||= id
      end

      # An index for the read object hash of a pdf template so that the
      # object hash does not need to be parsed multiple times when using
      # different pages of the pdf as page templates
      def hash_index
        @hash_index ||= {}
      end

      # reads and indexes a new IO for a template
      # if the IO has been indexed already then the parsed object hash
      # is returned directly
      def indexed_hash(input, io)
        hash_index[indexing_key(input)] ||= PDF::Reader::ObjectHash.new(io)
      end

      # the index key for the input.
      # uses object_id so that both a string filename or an IO stream can be
      # indexed and reused provided the same object gets used in multiple page
      # template calls.
      def indexing_key(input)
        input.object_id
      end

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
          raise PDF::Core::Errors::TemplateError, msg
        end

        if src_info
          @info = load_object_graph(hash, src_info).identifier
        end

        if src_root
          @root = load_object_graph(hash, src_root).identifier
        end
      rescue PDF::Reader::MalformedPDFError, PDF::Reader::InvalidObjectError => e
        msg = "Error reading template file. If you are sure it's a valid PDF, it may be a bug.\n#{e.message}"
        raise PDF::Core::Errors::TemplateError, msg
      rescue PDF::Reader::UnsupportedFeatureError
        msg = "Template file contains unsupported PDF features"
        raise PDF::Core::Errors::TemplateError, msg
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
          is_utf8?(object) ? object : PDF::Core::ByteString.new(object)
        else
          object
        end
      end
    end
  end
end

Prawn::Document::VALID_OPTIONS << :template
Prawn::Document.extensions << Prawn::Templates

PDF::Core::ObjectStore.send(:include, Prawn::Templates::ObjectStoreExtensions)
