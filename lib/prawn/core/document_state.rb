module Prawn
  module Core
    class DocumentState
      def initialize(options)
        normalize_metadata(options)

        @store   = Prawn::Core::ObjectStore.new(options[:info])

        @version                 = 1.3
        @pages                   = []
        @page                    = nil
        @trailer                 = {}
        @compress                = options.fetch(:compress, false)
        @optimize_objects        = options.fetch(:optimize_objects, false)
        @skip_encoding           = options.fetch(:skip_encoding, false)
        @before_render_callbacks = []
        @on_page_create_callback = nil
      end

      attr_accessor :store, :version, :pages, :page, :trailer, :compress, :optimize_objects,
                    :skip_encoding,   :before_render_callbacks, :on_page_create_callback

      def normalize_metadata(options)
        options[:info] ||= {}
        options[:info][:Creator] ||= "Prawn"
        options[:info][:Producer] = "Prawn"

        info = options[:info]

        info.keys.each do |key|
          if info[key].kind_of?(String)
            info[key] = Prawn::LiteralString.new(info[key])
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
          output << ref.object
        end
      end

    end
  end
end
