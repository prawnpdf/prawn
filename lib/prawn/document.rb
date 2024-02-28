# frozen_string_literal: true

require 'stringio'

require_relative 'document/bounding_box'
require_relative 'document/column_box'
require_relative 'document/internals'
require_relative 'document/span'

module Prawn
  # The `Prawn::Document` class is how you start creating a PDF document.
  #
  # There are three basic ways you can instantiate PDF Documents in Prawn, they
  # are through assignment, implicit block or explicit block. Below is an
  # example of each type, each example does exactly the same thing, makes a PDF
  # document with all the defaults and puts in the default font "Hello There"
  # and then saves it to the current directory as _example.pdf_.
  #
  # For example, assignment can be like this:
  #
  # ```ruby
  # pdf = Prawn::Document.new
  # pdf.text "Hello There"
  # pdf.render_file "example.pdf"
  # ```
  #
  # Or you can do an implied block form:
  #
  # ```ruby
  # Prawn::Document.generate "example.pdf" do
  #   text "Hello There"
  # end
  # ```
  #
  # Or if you need to access a variable outside the scope of the block, the
  # explicit block form:
  #
  # ```ruby
  # words = "Hello There"
  # Prawn::Document.generate "example.pdf" do |pdf|
  #   pdf.text words
  # end
  # ```
  #
  # Usually, the block forms are used when you are simply creating a PDF
  # document that you want to immediately save or render out.
  #
  # See the {#initialize new} and {.generate generate} methods for further
  # details on the above.
  class Document
    include Prawn::Document::Internals
    include PDF::Core::Annotations
    include PDF::Core::Destinations
    include Prawn::Document::Security
    include Prawn::Text
    include Prawn::Graphics
    include Prawn::Images
    include Prawn::Stamp
    include Prawn::SoftMask
    include Prawn::TransformationStack

    alias inspect to_s

    # @group Extension API

    # NOTE: We probably need to rethink the options validation system, but this
    # constant temporarily allows for extensions to modify the list.

    # List of recognised options.
    VALID_OPTIONS = %i[
      page_size page_layout margin left_margin
      right_margin top_margin bottom_margin skip_page_creation
      compress background info
      text_formatter print_scaling
    ].freeze

    # Any module added to this array will be included into instances of
    # {Prawn::Document} at the per-object level.  These will also be inherited
    # by any subclasses.
    #
    # @example
    #   module MyFancyModule
    #     def party!
    #       text "It's a big party!"
    #     end
    #   end
    #
    #   Prawn::Document.extensions << MyFancyModule
    #
    #   Prawn::Document.generate("foo.pdf") do
    #     party!
    #   end
    #
    # @return [Array<Module>]
    def self.extensions
      @extensions ||= []
    end

    # @private
    def self.inherited(base)
      super
      extensions.each { |e| base.extensions << e }
    end

    # @group Stable Attributes

    # Current margin box.
    # @return [Prawn::Document::BoundingBox]
    attr_accessor :margin_box

    # Current page margins.
    # @return [{:left, :top, :right, :bottom => Number}]
    attr_reader :margins

    # Absolute cursor position.
    # @return [Number]
    attr_reader :y

    # Current page number.
    # @return [Integer]
    attr_accessor :page_number

    # @group Extension Attributes

    # Current text formatter. By default it's {Text::Formatted::Parser}
    # @return [Object]
    attr_accessor :text_formatter

    # @group Stable API

    # Creates and renders a PDF document.
    #
    # When using the implicit block form, Prawn will evaluate the block
    # within an instance of {Prawn::Document}, simplifying your syntax.
    # However, please note that you will not be able to reference variables
    # from the enclosing scope within this block.
    #
    # ```ruby
    # # Using implicit block form and rendering to a file
    # Prawn::Document.generate "example.pdf" do
    #   # self here is set to the newly instantiated Prawn::Document
    #   # and so any variables in the outside scope are unavailable
    #   font "Times-Roman"
    #   draw_text "Hello World", at: [200,720], size: 32
    # end
    # ```
    #
    # If you need to access your local and instance variables, use the explicit
    # block form shown below. In this case, Prawn yields an instance of
    # {Prawn::Document} and the block is an ordinary closure:
    #
    # ```ruby
    # # Using explicit block form and rendering to a file
    # content = "Hello World"
    # Prawn::Document.generate "example.pdf" do |pdf|
    #   # self here is left alone
    #   pdf.font "Times-Roman"
    #   pdf.draw_text content, at: [200,720], size: 32
    # end
    # ```
    def self.generate(filename, options = {}, &block)
      pdf = new(options, &block)
      pdf.render_file(filename)
    end

    # Creates a new PDF Document.
    #
    # Setting e.g. the `:margin` to 100 points and the `:left_margin` to 50 will
    # result in margins of 100 points on every side except for the left, where
    # it will be 50.
    #
    # The `:margin` can also be an array much like CSS shorthand:
    #
    # ```ruby
    # # Top and bottom are 20, left and right are 100.
    # margin: [20, 100]
    # # Top is 50, left and right are 100, bottom is 20.
    # margin: [50, 100, 20]
    # # Top is 10, right is 20, bottom is 30, left is 40.
    # margin: [10, 20, 30, 40]
    # ```
    #
    # Additionally, `:page_size` can be specified as a simple two value array
    # giving the width and height of the document you need in PDF Points.
    #
    # @example New document, US Letter paper, portrait orientation
    #   pdf = Prawn::Document.new
    #
    # @example New document, A4 paper, landscaped
    #   pdf = Prawn::Document.new(page_size: "A4", page_layout: :landscape)
    #
    # @example New document, Custom size
    #   pdf = Prawn::Document.new(page_size: [200, 300])
    #
    # @example New document, with background
    #   pdf = Prawn::Document.new(
    #     background: "#{Prawn::DATADIR}/images/pigs.jpg"
    #   )
    #
    # @param options [Hash{Symbol => any}]
    # @option options :page_size [String, Array(Number, Number)] (LETTER)
    #   One of the `PDF::Core::PageGeometry` sizes.
    # @option options :page_layout [:portrait, :landscape]
    #   Page orientation.
    # @option options :margin [Number, Array<Number>] ([32])
    #   Sets the margin on all sides in points.
    # @option options :left_margin [Number] (32)
    #   Sets the left margin in points.
    # @option options :right_margin [Number] (32)
    #   Sets the right margin in points.
    # @option options :top_margin [Number] (32)
    #   Sets the top margin in points.
    # @option options :bottom_margin [Number] (32)
    #   Sets the bottom margin in points.
    # @option options :skip_page_creation [Boolean] (false)
    #   Creates a document without starting the first page.
    # @option options :compress [Boolean] (false)
    #   Compresses content streams before rendering them.
    # @option options :background [String?] (nil)
    #   An image path to be used as background on all pages.
    # @option options :background_scale [Number?] (1)
    #   Background image scale.
    # @option options :info [Hash{Symbol => any}?] (nil)
    #   Generic hash allowing for custom metadata properties.
    # @option options :text_formatter [Object] (Prawn::Text::Formatted::Parser)
    #  The text formatter to use for `:inline_format`ted text.
    def initialize(options = {}, &block)
      options = options.dup

      Prawn.verify_options(VALID_OPTIONS, options)

      # need to fix, as the refactoring breaks this
      # raise NotImplementedError if options[:skip_page_creation]

      self.class.extensions.reverse_each { |e| extend(e) }
      self.state = PDF::Core::DocumentState.new(options)
      state.populate_pages_from_store(self)
      renderer.min_version(state.store.min_version) if state.store.min_version

      renderer.min_version(1.6) if options[:print_scaling] == :none

      @background = options[:background]
      @background_scale = options[:background_scale] || 1
      @font_size = 12

      @bounding_box = nil
      @margin_box = nil

      @page_number = 0

      @text_formatter = options.delete(:text_formatter) ||
        Text::Formatted::Parser

      options[:size] = options.delete(:page_size)
      options[:layout] = options.delete(:page_layout)

      initialize_first_page(options)

      @bounding_box = @margin_box

      if block
        block.arity < 1 ? instance_eval(&block) : block[self]
      end
    end

    # @group Stable API

    # Creates and advances to a new page in the document.
    #
    # Page size, margins, and layout can also be set when generating a
    # new page. These values will become the new defaults for page creation.
    #
    # @example
    #   pdf.start_new_page #=> Starts new page keeping current values
    #   pdf.start_new_page(size: "LEGAL", :layout => :landscape)
    #   pdf.start_new_page(left_margin: 50, right_margin: 50)
    #   pdf.start_new_page(margin: 100)
    #
    # @param options [Hash]
    # @option options :margins [Hash{:left, :right, :top, :bottom => Number}, nil]
    #   ({ left: 0, right: 0, top: 0, bottom: 0 }) Page margins
    # @option options :crop [Hash{:left, :right, :top, :bottom => Number}, nil] (PDF::Core::Page::ZERO_INDENTS)
    #   Page crop box
    # @option options :bleed [Hash{:left, :right, :top, :bottom => Number},  nil] (PDF::Core::Page::ZERO_INDENTS)
    #   Page bleed box
    # @option options :trims [Hash{:left, :right, :top, :bottom => Number}, nil] (PDF::Core::Page::ZERO_INDENTS)
    #   Page trim box
    # @option options :art_indents [Hash{:left, :right, :top, :bottom => Number}, nil] (PDF::Core::Page::ZERO_INDENTS)
    #   Page art box indents.
    # @option options :graphic_state [PDF::Core::GraphicState, nil] (nil)
    #   Initial graphic state
    # @option options :size [String, Array<Number>, nil] ('LETTER')
    #   Page size. A string identifies a named page size defined in
    #   `PDF::Core::PageGeometry`. An array must be a two element array
    #   specifying width and height in points.
    # @option options :layout [:portrait, :landscape, nil] (:portrait)
    #   Page orientation.
    # @return [void]
    def start_new_page(options = {})
      last_page = state.page
      if last_page
        last_page_size = last_page.size
        last_page_layout = last_page.layout
        last_page_margins = last_page.margins.dup
      end

      page_options = {
        size: options[:size] || last_page_size,
        layout: options[:layout] || last_page_layout,
        margins: last_page_margins,
      }
      if last_page
        if last_page.graphic_state
          new_graphic_state = last_page.graphic_state.dup
        end

        # erase the color space so that it gets reset on new page for fussy
        # pdf-readers
        new_graphic_state&.color_space = {}

        page_options[:graphic_state] = new_graphic_state
      end

      state.page = PDF::Core::Page.new(self, page_options)

      apply_margin_options(options)
      generate_margin_box

      # Reset the bounding box if the new page has different size or layout
      if last_page && (last_page.size != state.page.size ||
                       last_page.layout != state.page.layout)
        @bounding_box = @margin_box
      end

      use_graphic_settings

      unless options[:orphan]
        state.insert_page(state.page, @page_number)
        @page_number += 1

        if @background
          canvas do
            image(@background, scale: @background_scale, at: bounds.top_left)
          end
        end
        @y = @bounding_box.absolute_top

        float do
          state.on_page_create_action(self)
        end
      end
    end

    # Remove page of the document by index.
    #
    # @example
    #   pdf = Prawn::Document.new
    #   pdf.page_count #=> 1
    #   3.times { pdf.start_new_page }
    #   pdf.page_count #=> 4
    #   pdf.delete_page(-1)
    #   pdf.page_count #=> 3
    #
    # @param index [Integer]
    # @return [Boolean]
    def delete_page(index)
      return false if index.abs > (state.pages.count - 1)

      state.pages.delete_at(index)

      state.store.pages.data[:Kids].delete_at(index)
      state.store.pages.data[:Count] -= 1
      @page_number -= 1
      true
    end

    # Number of pages in the document.
    #
    # @example
    #   pdf = Prawn::Document.new
    #   pdf.page_count #=> 1
    #   3.times { pdf.start_new_page }
    #   pdf.page_count #=> 4
    #
    # @return [Integer]
    def page_count
      state.page_count
    end

    # Re-opens the page with the given (1-based) page number so that you can
    # draw on it.
    #
    # @param page_number [Integer]
    # @return [void]
    def go_to_page(page_number)
      @page_number = page_number
      state.page = state.pages[page_number - 1]
      generate_margin_box
      @y = @bounding_box.absolute_top
    end

    # Set cursor absolute position.
    #
    # @param new_y [Number]
    # @return [new_y]
    def y=(new_y)
      @y = new_y
      bounds.update_height
    end

    # The current y drawing position relative to the innermost bounding box,
    # or to the page margins at the top level.
    #
    # @return [Number]
    def cursor
      y - bounds.absolute_bottom
    end

    # Moves to the specified y position in relative terms to the bottom margin.
    #
    # @param new_y [Number]
    # @return [void]
    def move_cursor_to(new_y)
      self.y = new_y + bounds.absolute_bottom
    end

    # Executes a block and then restores the original y position. If new pages
    # were created during this block, it will teleport back to the original
    # page when done.
    #
    # @example
    #   pdf.text "A"
    #
    #   pdf.float do
    #     pdf.move_down 100
    #     pdf.text "C"
    #   end
    #
    #   pdf.text "B"
    #
    # @return [void]
    def float
      original_page = page_number
      original_y = y
      yield
      go_to_page(original_page) unless page_number == original_page
      self.y = original_y
    end

    # Renders the PDF document to string.
    # Pass an open file descriptor to render to file.
    #
    # @overload render(output = nil)
    #   @param output [#<<]
    #   @return [String]
    def render(*arguments)
      (1..page_count).each do |i|
        go_to_page(i)
        repeaters.each { |r| r.run(i) }
      end

      renderer.render(*arguments)
    end

    # Renders the PDF document to file.
    #
    # @example
    #   pdf.render_file "foo.pdf"
    #
    # @param filename [String]
    # @return [void]
    def render_file(filename)
      File.open(filename, 'wb') { |f| render(f) }
    end

    # The bounds method returns the current bounding box you are currently in,
    # which is by default the box represented by the margin box on the
    # document itself. When called from within a created `bounding_box`
    # block, the box defined by that call will be returned instead of the
    # document margin box.
    #
    # Another important point about bounding boxes is that all x and
    # y measurements within a bounding box code block are relative to the bottom
    # left corner of the bounding box.
    #
    # @example
    #  Prawn::Document.new do
    #    # In the default "margin box" of a Prawn document of 0.5in along each
    #    # edge
    #
    #    # Draw a border around the page (the manual way)
    #    stroke do
    #      line(bounds.bottom_left, bounds.bottom_right)
    #      line(bounds.bottom_right, bounds.top_right)
    #      line(bounds.top_right, bounds.top_left)
    #      line(bounds.top_left, bounds.bottom_left)
    #    end
    #
    #    # Draw a border around the page (the easy way)
    #    stroke_bounds
    #  end
    #
    # @return [Prawn::Document::BoundingBox]
    def bounds
      @bounding_box
    end

    # Returns the innermost non-stretchy bounding box.
    #
    # @private
    # @return [Prawn::Document::BoundingBox]
    def reference_bounds
      @bounding_box.reference_bounds
    end

    # Sets {Document#bounds} to the {BoundingBox} provided. See {#bounds} for
    # a brief description of what a bounding box is. This function is useful if
    # you really need to change the bounding box manually, but usually, just
    # entering and exiting bounding box code blocks is good enough.
    #
    # @param bounding_box [Prawn::Document::BoundingBox]
    # @return [bounding_box]
    def bounds=(bounding_box)
      @bounding_box = bounding_box
    end

    # Moves up the document by n points relative to the current position inside
    # the current bounding box.
    #
    # @param amount [Number]
    # @return [void]
    def move_up(amount)
      self.y += amount
    end

    # Moves down the document by n points relative to the current position
    # inside the current bounding box.
    #
    # @param amount [Number]
    # @return [void]
    def move_down(amount)
      self.y -= amount
    end

    # Moves down the document and then executes a block.
    #
    # @example
    #   pdf.text "some text"
    #   pdf.pad_top(100) do
    #     pdf.text "This is 100 points below the previous line of text"
    #   end
    #   pdf.text "This text appears right below the previous line of text"
    #
    # @param y [Number]
    # @return [void]
    # @yield
    def pad_top(y)
      move_down(y)
      yield
    end

    # Executes a block then moves down the document
    #
    # @example
    #   pdf.text "some text"
    #   pdf.pad_bottom(100) do
    #     pdf.text "This text appears right below the previous line of text"
    #   end
    #   pdf.text "This is 100 points below the previous line of text"
    #
    # @param y [Number]
    # @return [void]
    # @yield
    def pad_bottom(y)
      yield
      move_down(y)
    end

    # Moves down the document by y, executes a block, then moves down the
    # document by y again.
    #
    # @example
    #   pdf.text "some text"
    #   pdf.pad(100) do
    #     pdf.text "This is 100 points below the previous line of text"
    #   end
    #   pdf.text "This is 100 points below the previous line of text"
    #
    # @param y [Number]
    # @return [void]
    # @yield
    def pad(y)
      move_down(y)
      yield
      move_down(y)
    end

    # Indents the specified number of PDF points for the duration of the block
    #
    # @example
    #  pdf.text "some text"
    #  pdf.indent(20) do
    #    pdf.text "This is indented 20 points"
    #  end
    #  pdf.text "This starts 20 points left of the above line " +
    #           "and is flush with the first line"
    #  pdf.indent 20, 20 do
    #    pdf.text "This line is indented on both sides."
    #  end
    #
    # @param left [Number]
    # @param right [Number]
    # @yield
    # @return [void]
    def indent(left, right = 0, &block)
      bounds.indent(left, right, &block)
    end

    # Places a text box on specified pages for page numbering.  This should be
    # called towards the end of document creation, after all your content is
    # already in place. In your template string, `<page>` refers to the current
    # page, and `<total>` refers to the total amount of pages in the document.
    # Page numbering should occur at the end of your {Prawn::Document.generate}
    # block because the method iterates through existing pages after they are
    # created.
    #
    # Please refer to {Prawn::Text#text_box} for additional options concerning
    # text formatting and placement.
    #
    # @example Print page numbers on every page except for the first. Start counting from five.
    #   Prawn::Document.generate("page_with_numbering.pdf") do
    #     number_pages "<page> in a total of <total>", {
    #       start_count_at: 5,
    #       page_filter: lambda { |pg| pg != 1 },
    #       at: [bounds.right - 50, 0],
    #       align: :right,
    #       size: 14
    #     }
    #   end
    #
    # @param string [String] Template string for page number wording.
    #   Should include `<page>` and, optionally, `<total>`.
    # @param options [Hash{Symbol => any}] A hash for page numbering and text box options.
    # @option options :page_filter []
    #   A filter to specify which pages to place page numbers on. Refer to the method {#page_match?}
    # @option options :start_count_at [Integer]
    #   The starting count to increment pages from.
    # @option options :total_pages [Integer]
    #   If provided, will replace `<total>` with the value given. Useful to
    #   override the total number of pages when using the start_count_at option.
    # @option options :color [String, Array<Number>] Text fill color.
    def number_pages(string, options = {})
      opts = options.dup
      start_count_at = opts.delete(:start_count_at)

      page_filter =
        if opts.key?(:page_filter)
          opts.delete(:page_filter)
        else
          :all
        end

      total_pages = opts.delete(:total_pages)
      txtcolor = opts.delete(:color)
      # An explicit height so that we can draw page numbers in the margins
      opts[:height] = 50 unless opts.key?(:height)

      start_count = false
      pseudopage = 0
      (1..page_count).each do |p|
        unless start_count
          pseudopage =
            case start_count_at
            when String
              Integer(start_count_at, 10)
            when (1..)
              Integer(start_count_at)
            else
              1
            end
        end
        if page_match?(page_filter, p)
          go_to_page(p)
          # have to use fill_color here otherwise text reverts back to default
          # fill color
          fill_color(txtcolor) unless txtcolor.nil?
          total_pages = page_count if total_pages.nil?
          str = string.gsub('<page>', pseudopage.to_s)
            .gsub('<total>', total_pages.to_s)
          text_box(str, opts)
          start_count = true # increment page count as soon as first match found
        end
        pseudopage += 1 if start_count
      end
    end

    # @group Experimental API

    # @private
    def group(*_arguments)
      raise NotImplementedError,
        'Document#group has been disabled because its implementation ' \
          'lead to corrupted documents whenever a page boundary was ' \
          'crossed. We will try to work on reimplementing it in a ' \
          'future release'
    end

    # @private
    def transaction
      raise NotImplementedError,
        'Document#transaction has been disabled because its implementation ' \
          'lead to corrupted documents whenever a page boundary was ' \
          'crossed. We will try to work on reimplementing it in a ' \
          'future release'
    end

    # Provides a way to execute a block of code repeatedly based on a
    # page_filter.
    #
    # Available page filters are:
    #   :all         repeats on every page
    #   :odd         repeats on odd pages
    #
    # @param page_filter [:all, :odd, :even, Array<Number>, Range, Proc]
    #   * `:all`: repeats on every page
    #   * `:odd`: repeats on odd pages
    #   * `:even`: repeats on even pages
    #   * array: repeats on every page listed in the array
    #   * range: repeats on every page included in the range
    #   * lambda: yields page number and repeats for true return values
    # @param page_number [Integer]
    # @return [Boolean]
    def page_match?(page_filter, page_number)
      case page_filter
      when :all
        true
      when :odd
        page_number.odd?
      when :even
        page_number.even?
      when Range, Array
        page_filter.include?(page_number)
      when Proc
        page_filter.call(page_number)
      end
    end

    # @private
    def mask(*fields)
      # Stores the current state of the named attributes, executes the block,
      # and then restores the original values after the block has executed.
      # -- I will remove the nodoc if/when this feature is a little less hacky
      stored = {}
      fields.each { |f| stored[f] = public_send(f) }
      yield
      fields.each { |f| public_send(:"#{f}=", stored[f]) }
    end

    # @group Extension API

    # Initializes the first page in a new document.
    # This methods allows customisation of this process in extensions such as
    # Prawn::Template.
    #
    # @param options [Hash]
    # @return [void]
    def initialize_first_page(options)
      if options[:skip_page_creation]
        start_new_page(options.merge(orphan: true))
      else
        start_new_page(options)
      end
    end

    ## Internals. Don't depend on them!

    # @private
    attr_accessor :state

    # @private
    def page
      state.page
    end

    private

    # setting override_settings to true ensures that a new graphic state does
    # not end up using previous settings.
    def use_graphic_settings(override_settings = false)
      set_fill_color if current_fill_color != '000000' || override_settings
      set_stroke_color if current_stroke_color != '000000' || override_settings
      write_line_width if line_width != 1 || override_settings
      write_stroke_cap_style if cap_style != :butt || override_settings
      write_stroke_join_style if join_style != :miter || override_settings
      write_stroke_dash if dashed? || override_settings
    end

    def generate_margin_box
      old_margin_box = @margin_box
      page = state.page

      @margin_box = BoundingBox.new(
        self,
        nil, # margin box has no parent
        [page.margins[:left], page.dimensions[-1] - page.margins[:top]],
        width: page.dimensions[-2] -
          (page.margins[:left] + page.margins[:right]),
        height: page.dimensions[-1] -
          (page.margins[:top] + page.margins[:bottom]),
      )

      # This check maintains indentation settings across page breaks
      if old_margin_box
        @margin_box.add_left_padding(old_margin_box.total_left_padding)
        @margin_box.add_right_padding(old_margin_box.total_right_padding)
      end

      # we must update bounding box if not flowing from the previous page
      #
      @bounding_box = @margin_box unless @bounding_box&.parent
    end

    def apply_margin_options(options)
      sides = %i[top right bottom left]
      margin = Array(options[:margin])

      # Treat :margin as CSS shorthand with 1-4 values.
      positions = {
        4 => [0, 1, 2, 3],
        3 => [0, 1, 2, 1],
        2 => [0, 1, 0, 1],
        1 => [0, 0, 0, 0],
        0 => [],
      }[margin.length]

      sides.zip(positions).each do |side, pos|
        new_margin = options[:"#{side}_margin"] || (margin[pos] if pos)
        state.page.margins[side] = new_margin if new_margin
      end
    end

    def font_metric_cache # :nodoc:
      @font_metric_cache ||= FontMetricCache.new(self)
    end
  end
end
