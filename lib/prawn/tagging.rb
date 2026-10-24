# frozen_string_literal: true

module Prawn
  # Tagged PDF: a logical structure (headings, paragraphs, figures, ...) that
  # assistive technology such as screen readers uses to read the document.
  #
  # Create the document with `tagged: true`. In a tagged document every piece
  # of content should be either part of a structure element or an artifact.
  # Content drawn outside both is left unmarked, and accessibility checkers
  # report it. Assistive technology also needs embedded fonts, so use a
  # TrueType or OpenType font instead of the built-in ones.
  #
  # Prawn marks the content it draws on its own as artifacts: page backgrounds,
  # repeaters, page numbers and the `on_page_create` callback. Links in
  # formatted text become `Link` elements.
  #
  # @example
  #   pdf = Prawn::Document.new(tagged: true, language: 'en-GB')
  #   pdf.structure(:H1) { pdf.text 'Annual report' }
  #   pdf.structure(:P) { pdf.text 'Paragraphs can run over page breaks.' }
  #   pdf.structure(:Figure, Alt: 'Company logo') { pdf.image 'logo.png' }
  #   pdf.artifact(Type: :Layout) { pdf.stroke_horizontal_rule }
  module Tagging
    # @group Stable API

    # Whether this document is tagged.
    #
    # @return [Boolean]
    def tagged?
      !state.structure_tree.nil?
    end

    # Makes content drawn in the block a structure element. Elements nest:
    # an element opened inside another becomes its child.
    #
    # In an untagged document this only yields.
    #
    # @example A list
    #   pdf.structure(:L) do
    #     pdf.structure(:LI) { pdf.text '• First item' }
    #     pdf.structure(:LI) { pdf.text '• Second item' }
    #   end
    #
    # @param type [Symbol] a standard structure type (section *14.8.4
    #   Standard Structure Types* in PDF 1.7 spec), e.g. `:H1`, `:P`, `:L`,
    #   `:LI`, `:Table`, `:TR`, `:TH`, `:TD`, `:Figure`, `:Span`
    # @param attributes [Hash] additional structure element entries, e.g.
    #   `Alt:` (alternate description, required for figures), `ActualText:`,
    #   `Lang:`
    # @yield
    # @return [void]
    def structure(type, attributes = {}, &block)
      return yield unless tagged?

      state.structure_tree.element(type, attributes, &block)
    end

    # Makes content drawn in the block an artifact: content that is not part
    # of the document's logical structure, such as decoration, page numbers,
    # running headers and footers.
    #
    # In an untagged document this only yields.
    #
    # @param properties [Hash] artifact properties (section *14.8.2.2 Real
    #   Content and Artifacts* in PDF 1.7 spec), e.g.
    #   `Type: :Pagination, Subtype: :Footer`
    # @yield
    # @return [void]
    def artifact(properties = {}, &block)
      return yield unless tagged?

      state.structure_tree.artifact(properties, &block)
    end
  end
end
