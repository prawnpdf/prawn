warn "Templates are no longer supported in Prawn!\n" +
     "This code is for experimental testing only, and\n" +
     "will extracted into its own gem in a future Prawn release"

module Prawn
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
  end
end

Prawn::Document::VALID_OPTIONS << :template
Prawn::Document.extensions << Prawn::Templates
