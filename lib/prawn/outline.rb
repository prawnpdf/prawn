# frozen_string_literal: true

module Prawn
  class Document # rubocop: disable Style/Documentation
    # @group Stable API

    # Lazily instantiates a Prawn::Outline object for document. This is used as
    # point of entry to methods to build the outline tree for a document's table
    # of contents.
    #
    # @return [Prawn::Outline]
    def outline
      @outline ||= Outline.new(self)
    end
  end

  # The Outline class organizes the outline tree items for the document. Note
  # that the {prev} and {parent} are adjusted while navigating through the
  # nested blocks. These attributes along with the presence or absence of blocks
  # are the primary means by which the relations for the various
  # `PDF::Core::OutlineItem`s and the `PDF::Core::OutlineRoot` are set.
  #
  # Some ideas for the organization of this class were gleaned from `name_tree`.
  # In particular the way in which the `PDF::Core::OutlineItem`s are finally
  # rendered into document objects through a hash.
  class Outline
    # @private
    attr_accessor :parent, :prev, :document, :items

    # @param document [Prawn::Document]
    def initialize(document)
      @document = document
      @parent = root
      @prev = nil
      @items = {}
    end

    # @group Stable API

    # Returns the current page number of the document.
    #
    # @return [Integer]
    def page_number
      @document.page_number
    end

    # Defines/Updates an outline for the document.
    #
    # The outline is an optional nested index that appears on the side of a PDF
    # document usually with direct links to pages. The outline DSL is defined by
    # nested blocks involving two methods: {section} and {page}. Note that one
    # can also use {update} to add more sections to the end of the outline tree
    # using the same syntax and scope.
    #
    # The syntax is best illustrated with an example:
    #
    # ```ruby
    # Prawn::Document.generate('outlined_document.pdf') do
    #   text "Page 1. This is the first Chapter. "
    #   start_new_page
    #   text "Page 2. More in the first Chapter. "
    #   start_new_page
    #   outline.define do
    #     section 'Chapter 1', destination: 1, closed: true do
    #       page destination: 1, title: 'Page 1'
    #       page destination: 2, title: 'Page 2'
    #     end
    #   end
    #   start_new_page do
    #   outline.update do
    #     section 'Chapter 2', destination: 2, do
    #       page destination: 3, title: 'Page 3'
    #     end
    #   end
    # end
    # ```
    #
    # @yield
    # @return [void]
    def define(&block)
      instance_eval(&block) if block
    end

    alias update define

    # Inserts an outline section to the outline tree (see {define}).
    #
    # Although you will probably choose to exclusively use {define} so that your
    # outline tree is contained and easy to manage, this method gives you the
    # option to insert sections to the outline tree at any point during document
    # generation. This method allows you to add a child subsection to any other
    # item at any level in the outline tree. Currently the only way to locate
    # the place of entry is with the title for the item. If your title names are
    # not unique consider using {define}.
    #
    # Consider using this method instead of {update} if you want to have the
    # outline object to be scoped as self (see {insert_section_after} example).
    #
    # ```ruby
    # go_to_page 2
    # start_new_page
    # text "Inserted Page"
    # outline.add_subsection_to title: 'Page 2', :first do
    #   outline.page destination: page_number, title: "Inserted Page"
    # end
    # ```
    #
    # @param title [String] An outline title to add the subsection to.
    # @param position [:first, :last] (:last)
    #   Where the subsection will be placed relative to other child elements. If
    #   you need to position your subsection in between other elements then
    #   consider using {insert_section_after}.
    # @yield Uses the same DSL syntax as {define}
    # @return [void]
    def add_subsection_to(title, position = :last, &block)
      @parent = items[title]
      unless @parent
        raise Prawn::Errors::UnknownOutlineTitle,
          "\n No outline item with title: '#{title}' exists in the outline tree"
      end
      @prev = position == :first ? nil : @parent.data.last
      nxt = position == :first ? @parent.data.first : nil
      insert_section(nxt, &block)
    end

    # Inserts an outline section to the outline tree (see {define}).
    #
    # Although you will probably choose to exclusively use {define} so that your
    # outline tree is contained and easy to manage, this method gives you the
    # option to insert sections to the outline tree at any point during document
    # generation. Unlike {add_subsection_to}, this method allows you to enter
    # a section after any other item at any level in the outline tree.
    # Currently the only way to locate the place of entry is with the title for
    # the item. If your title names are not unique consider using
    # {define}.
    #
    # @example
    #   go_to_page 2
    #   start_new_page
    #   text "Inserted Page"
    #   update_outline do
    #     insert_section_after :title => 'Page 2' do
    #       page :destination => page_number, :title => "Inserted Page"
    #     end
    #   end
    #
    # @param title [String]
    #   The title of other section or page to insert new section after.
    # @yield Uses the same DSL syntax as {define}.
    # @return [void]
    def insert_section_after(title, &block)
      @prev = items[title]
      unless @prev
        raise Prawn::Errors::UnknownOutlineTitle,
          "\n No outline item with title: '#{title}' exists in the outline tree"
      end
      @parent = @prev.data.parent
      nxt = @prev.data.next
      insert_section(nxt, &block)
    end

    # Adds an outline section to the outline tree.
    #
    # Although you will probably choose to exclusively use {define} so that your
    # outline tree is contained and easy to manage, this method gives you the
    # option to add sections to the outline tree at any point during document
    # generation. When not being called from within another {section} block the
    # section will be added at the top level after the other root elements of
    # the outline. For more flexible placement try using {insert_section_after}
    # and/or {add_subsection_to}.
    #
    # @example
    #   outline.section 'Added Section', destination: 3 do
    #     outline.page destionation: 3, title: 'Page 3'
    #   end
    #
    # @param title [String] The outline text that appears for the section.
    # @param options [Hash{Symbol => any}]
    # @option options :destination [Integer, Array]
    #   - Optional page number for a destination link to the top of the page
    #     (using a `:FIT` destination).
    #   - An array with a custom destination (see the `#dest_*` methods of the
    #     `PDF::Core::Destination` module).
    # @option options :closed [Boolean] (false)
    #   Whether the section should show its nested outline elements.
    # @yield More nested subsections and/or page blocks.
    # @return [void]
    def section(title, options = {}, &block)
      add_outline_item(title, options, &block)
    end

    # Adds a page to the outline.
    #
    # Although you will probably choose to exclusively use {define} so that your
    # outline tree is contained and easy to manage, this method also gives you
    # the option to add pages to the root of outline tree at any point during
    # document generation. Note that the page will be added at the top level
    # after the other root outline elements. For more flexible placement try
    # using {insert_section_after} and/or {add_subsection_to}.
    #
    # @note This method is almost identical to {section} except that it does not
    #   accept a block thereby defining the outline item as a leaf on the
    #   outline tree structure.
    #
    # @example
    #   outline.page title: "Very Last Page"
    #
    # @param options [Hash{Symbol => any}]
    # @option options :title [String] REQUIRED.
    #   The outline text that appears for the page.
    # @option options :destination [Integer, Array]
    #   - The page number for a destination link to the top of the page (using
    #     a `:FIT` destination).
    #   - An array with a custom destination (see the `#dest_*` methods of the
    #     `PDF::Core::Destination` module).
    # @option options :closed [Boolean] (false)
    #   Whether the section should show its nested outline elements.
    # @return [void]
    def page(options = {})
      if options[:title]
        title = options[:title]
      else
        raise Prawn::Errors::RequiredOption,
          "\nTitle is a required option for page"
      end
      add_outline_item(title, options)
    end

    private

    # The Outline dictionary (12.3.3) for this document.  It is
    # lazily initialized, so that documents that do not have an outline
    # do not incur the additional overhead.
    def root
      document.state.store.root.data[:Outlines] ||=
        document.ref!(PDF::Core::OutlineRoot.new)
    end

    def add_outline_item(title, options, &block)
      outline_item = create_outline_item(title, options)
      establish_relations(outline_item)
      increase_count
      set_variables_for_block(outline_item, block)
      yield if block
      reset_parent(outline_item)
    end

    def create_outline_item(title, options)
      outline_item = PDF::Core::OutlineItem.new(title, parent, options)

      case options[:destination]
      when Integer
        page_index = options[:destination] - 1
        outline_item.dest = [document.state.pages[page_index].dictionary, :Fit]
      when Array
        outline_item.dest = options[:destination]
      end

      outline_item.prev = prev if @prev
      items[title] = document.ref!(outline_item)
    end

    def establish_relations(outline_item)
      prev.data.next = outline_item if prev
      parent.data.first = outline_item unless prev
      parent.data.last = outline_item
    end

    def increase_count
      counting_parent = parent
      while counting_parent
        counting_parent.data.count += 1
        counting_parent =
          if counting_parent == root
            nil
          else
            counting_parent.data.parent
          end
      end
    end

    def set_variables_for_block(outline_item, block)
      self.prev = block ? nil : outline_item
      self.parent = outline_item if block
    end

    def reset_parent(outline_item)
      if parent == outline_item
        self.prev = outline_item
        self.parent = outline_item.data.parent
      end
    end

    def insert_section(nxt, &block)
      last = @parent.data.last
      if block
        yield
      end
      adjust_relations(nxt, last)
      reset_root_positioning
    end

    def adjust_relations(nxt, last)
      if nxt
        nxt.data.prev = @prev
        @prev.data.next = nxt
        @parent.data.last = last
      end
    end

    def reset_root_positioning
      @parent = root
      @prev = root.data.last
    end
  end
end
