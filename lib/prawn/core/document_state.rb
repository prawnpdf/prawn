module Prawn
  module Core
    class DocumentState #:nodoc:
      def initialize(options)
        normalize_metadata(options)

        if options[:template]
          @store = Prawn::Core::ObjectStore.new(:template => options[:template])
        else
          @store = Prawn::Core::ObjectStore.new(:info => options[:info])
        end

        @version                 = 1.3
        @pages                   = []
        @page                    = nil
        @trailer                 = {}
        @compress                = options.fetch(:compress, false)
        @encrypt                 = options.fetch(:encrypt, false)
        @encryption_key          = options[:encryption_key]
        @optimize_objects        = options.fetch(:optimize_objects, false)
        @skip_encoding           = options.fetch(:skip_encoding, false)
        @before_render_callbacks = []
        @on_page_create_callback = nil
      end

      attr_accessor :store, :version, :pages, :page, :trailer, :compress,
        :encrypt, :encryption_key, :optimize_objects, :skip_encoding,
        :before_render_callbacks, :on_page_create_callback

      def populate_pages_from_store(document)
        return 0 if @store.page_count <= 0 || @pages.size > 0

        count = (1..@store.page_count)
        @pages = count.map do |index|
          orig_dict_id = @store.object_id_for_page(index)
          Prawn::Core::Page.new(document, :object_id => orig_dict_id)
        end

      end

      def normalize_metadata(options)
        options[:info] ||= {}
        options[:info][:Creator] ||= "Prawn"
        options[:info][:Producer] = "Prawn"

        info = options[:info]

        info.keys.each do |key|
          if info[key].kind_of?(String)
            info[key] = Prawn::Core::LiteralString.new(info[key])
          end
        end
      end

      def insert_page(page, page_number)
        pages.insert(page_number, page)
        store.pages.data[:Kids].insert(page_number, page.dictionary)
        store.pages.data[:Count] += 1
      end

      def on_page_create_action(doc)
        on_page_create_callback[doc] if on_page_create_callback
      end

      def before_render_actions(doc)
        before_render_callbacks.each{ |c| c.call(self) }
      end

      def page_count
        pages.length
      end

      def render_body(output)
        store.compact if optimize_objects
        store.each do |ref|
          ref.offset = output.size
          output << (@encrypt ? ref.encrypted_object(@encryption_key) : 
                                ref.object)
        end
      end

    end
  end
end
