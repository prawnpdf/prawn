# frozen_string_literal: true

module Prawn
  class Document # rubocop: disable Style/Documentation
    # A list of all repeaters in the document.
    # See {repeat} for details.
    #
    # @private
    # @return [Array]
    def repeaters
      @repeaters ||= []
    end

    # @group Experimental API

    # Provides a way to execute a block of code repeatedly based on
    # a `page_filter`. Since Stamp is used under the hood, this method is very
    # space efficient.
    #
    # Also accepts an optional second argument for dynamic content which
    # executes the code in the context of the filtered pages without using
    # a Stamp.
    #
    # @example
    #   Prawn::Document.generate("repeat.pdf", skip_page_creation: true) do
    #     repeat :all do
    #       draw_text "ALLLLLL", at: bounds.top_left
    #     end
    #
    #     repeat :odd do
    #       draw_text "ODD", at: [0, 0]
    #     end
    #
    #     repeat :even do
    #       draw_text "EVEN", at: [0, 0]
    #     end
    #
    #     repeat [1, 2] do
    #       draw_text "[1, 2]", at: [100, 0]
    #     end
    #
    #     repeat 2..4 do
    #       draw_text "2..4", at: [200, 0]
    #     end
    #
    #     repeat(lambda { |pg| pg % 3 == 0 }) do
    #       draw_text "Every third", at: [250, 20]
    #     end
    #
    #     10.times do
    #       start_new_page
    #       draw_text "A wonderful page", at: [400, 400]
    #     end
    #
    #     repeat(:all, dynamic: true) do
    #       text page_number, at: [500, 0]
    #     end
    #   end
    #
    # @param page_filter [:all, :odd, :even, Array<Integer>, Range, Proc]
    #   Pages to draw the repeater content on.
    #
    #   Available page filters are:
    #
    #   - `:all` -- repeats on every page.
    #   - `:odd` -- repeats on odd pages.
    #   - `:even` -- repeats on even pages.
    #   - Array of Integers -- repeats on every page listed in the array.
    #   - Range -- repeats on every page included in the range.
    #   - Proc -- yields page number and repeats for true return values.
    # @param options [Hash]
    # @option options :dynamic [Boolean] (false)
    #   A dynamic repeater executes block on every matched page. A static
    #   repeater uses {stamp} to prepare the content (runs the block once) and
    #   puts it on every matched page.
    # @return [void]
    def repeat(page_filter, options = {}, &block)
      dynamic = options.fetch(:dynamic, false)
      repeaters << Prawn::Repeater.new(
        self, page_filter, dynamic, &block
      )
    end
  end

  # Repeater object.
  #
  # @private
  class Repeater
    class << self
      attr_writer :count

      # Repeater counter.
      #
      # It's not an exact number of repeaters but a counter used to generate
      # unique repeater stamp names.
      #
      # @return [Integer]
      def count
        @count ||= 0
      end
    end

    attr_reader :name

    def initialize(document, page_filter, dynamic = false, &block)
      @document = document
      @page_filter = page_filter
      @dynamic = dynamic
      @stamp_name = "prawn_repeater(#{Repeater.count})"
      @document.create_stamp(@stamp_name, &block) unless dynamic
      @block = block if dynamic
      @graphic_state = document.state.page.graphic_state.dup

      Repeater.count += 1
    end

    # Should this repeater run on this page?
    #
    # @param page_number [Integer]
    # @return [Boolean]
    def match?(page_number)
      @document.page_match?(@page_filter, page_number)
    end

    # Run repeater.
    #
    # @param page_number [Integer]
    # @return [void]
    def run(page_number)
      if !@dynamic
        @document.stamp(@stamp_name) if match?(page_number)
      elsif @block && match?(page_number)
        @document.save_graphics_state(@graphic_state) do
          @document.__send__(:freeze_stamp_graphics)
          @block.call
        end
      end
    end
  end
end
