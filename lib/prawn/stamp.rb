# frozen_string_literal: true

module Prawn
  # This module is used to create content that will be included multiple times
  # in a document. Using a stamp has three advantages over creating content anew
  # each time it is placed on the page:
  # * Faster document creation.
  # * Smaller final document.
  # * Faster display on subsequent displays of the repeated element because the
  #   viewer application can cache the rendered results.
  #
  # @example
  #   pdf.create_stamp("my_stamp") {
  #     pdf.fill_circle([10, 15], 5)
  #     pdf.draw_text("hello world", at: [20, 10])
  #   }
  #   pdf.stamp("my_stamp")
  module Stamp
    # @group Stable API

    # Renders the stamp.
    #
    # @example
    #   pdf.create_stamp("my_stamp") {
    #     pdf.fill_circle([10, 15], 5)
    #     pdf.text("hello world", at: [20, 10])
    #   }
    #   pdf.stamp("my_stamp")
    #
    # @param name [String]
    # @return [void]
    # @raise [Prawn::Errors::InvalidName] if name is empty.
    # @raise [Prawn::Errors::UndefinedObjectName] if no stamp has been created
    #   with this name.
    def stamp(name)
      dictionary_name, dictionary = stamp_dictionary(name)
      renderer.add_content("/#{dictionary_name} Do")
      update_annotation_references(dictionary.data[:Annots])
      state.page.xobjects.merge!(dictionary_name => dictionary)
    end

    # Renders the stamp at a position offset from the initial coords at which
    # the elements of the stamp was created.
    #
    # @example
    #   pdf.create_stamp("circle") do
    #     pdf.fill_circle([0, 0], 25)
    #   end
    #   # draws a circle at 100, 100
    #   pdf.stamp_at("circle", [100, 100])
    #
    # @param name [String]
    # @param point [Array(Number, Number)]
    # @return [void]
    # @see [stamp] for exceptions that might be raised.
    def stamp_at(name, point)
      translate(point[0], point[1]) { stamp(name) }
    end

    # Creates a re-usable stamp.
    #
    # @example
    #   pdf.create_stamp("my_stamp") {
    #     pdf.fill_circle([10, 15], 5)
    #     pdf.draw_text("hello world", at: [20, 10])
    #   }
    #
    # @param name [String] Stamp name.
    # @yield Stamp content.
    # @return [void]
    # @raise [Prawn::Errors::NameTaken]
    #   if a stamp already exists in this document with this name.
    # @raise [Prawn::Errors::InvalidName] if name is empty.
    def create_stamp(name, &block)
      dictionary = create_stamp_dictionary(name)

      state.page.stamp_stream(dictionary, &block)
    end

    private

    def stamp_dictionary_registry
      @stamp_dictionary_registry ||= {}
    end

    def next_stamp_dictionary_id
      stamp_dictionary_registry.length + 1
    end

    def stamp_dictionary(name)
      raise Prawn::Errors::InvalidName if name.empty?
      if stamp_dictionary_registry[name].nil?
        raise Prawn::Errors::UndefinedObjectName
      end

      dict = stamp_dictionary_registry[name]

      dictionary_name = dict[:stamp_dictionary_name]
      dictionary = dict[:stamp_dictionary]
      [dictionary_name, dictionary]
    end

    def create_stamp_dictionary(name)
      raise Prawn::Errors::InvalidName if name.empty?
      raise Prawn::Errors::NameTaken unless stamp_dictionary_registry[name].nil?

      # BBox origin is the lower left margin of the page, so we need
      # it to be the full dimension of the page, or else things that
      # should appear near the top or right margin are invisible
      dictionary = ref!(
        Type: :XObject,
        Subtype: :Form,
        BBox: [
          0, 0,
          state.page.dimensions[2], state.page.dimensions[3],
        ],
      )

      dictionary_name = "Stamp#{next_stamp_dictionary_id}"

      stamp_dictionary_registry[name] = {
        stamp_dictionary_name: dictionary_name,
        stamp_dictionary: dictionary,
      }
      dictionary
    end

    # Referencing annotations from a stamp XObject doesn't result
    # in a working link. Instead, the references must be appended
    # to the /Annot dictionary of the object that contains the
    # call to the stamp object.
    def update_annotation_references(annots)
      if annots&.any?
        state.page.dictionary.data[:Annots] ||= []
        state.page.dictionary.data[:Annots] |= annots
      end
    end

    def freeze_stamp_graphics
      update_colors
      write_line_width
      write_stroke_cap_style
      write_stroke_join_style
      write_stroke_dash
    end
  end
end
