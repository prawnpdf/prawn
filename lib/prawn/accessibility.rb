# frozen_string_literal: true

module Prawn
  # Provides tagged PDF (accessibility) support for Prawn documents.
  #
  # When a document is created with `marked: true`, all content can be
  # wrapped in structure elements that screen readers and assistive
  # technologies use to navigate the document.
  #
  # @example
  #   pdf = Prawn::Document.new(marked: true, language: 'en-US')
  #
  #   pdf.structure(:H1) do
  #     pdf.text 'Document Title'
  #   end
  #
  #   pdf.structure(:P) do
  #     pdf.text 'Body paragraph text.'
  #   end
  #
  #   pdf.artifact do
  #     pdf.text 'Page 1'  # not read by screen readers
  #   end
  module Accessibility
    # Whether this document is tagged for accessibility.
    #
    # @return [Boolean]
    def tagged?
      renderer.marked?
    end

    # Wrap content in a structure element. The block's content will be
    # associated with the given tag in the document's structure tree.
    #
    # Can be nested — inner structure calls become children of the outer.
    #
    # @param tag [Symbol] PDF structure type (:Document, :Part, :Sect,
    #   :H1-:H6, :P, :L, :LI, :Lbl, :LBody, :Table, :TR, :TH, :TD,
    #   :Figure, :Formula, :Form, :Span, :Link, :Note, :BlockQuote,
    #   :Caption, :TOC, :TOCI, :Reference)
    # @param attributes [Hash] optional attributes
    # @option attributes [String] :Alt alternative text (for Figure, Formula)
    # @option attributes [String] :ActualText replacement text for screen
    #   readers (e.g., "required" for "*", "selected" for "X")
    # @option attributes [String] :Lang language override for this element
    # @option attributes [Symbol] :Scope table header scope (:Column, :Row, :Both)
    # @yield content to render inside this structure element
    # @return [void]
    def structure(tag, attributes = {}, &block)
      return yield if !tagged? || !block

      tree = renderer.structure_tree
      tree.begin_element(tag, attributes)
      tree.mark_content(tag, &block)
      tree.end_element
    end

    # Wrap content in a structure element without marking the content
    # directly. Use this for container elements (Table, TR, L, LI) where
    # the children will each have their own marked content.
    #
    # @param tag [Symbol] PDF structure type
    # @param attributes [Hash] optional attributes
    # @yield content to render inside this structure element
    # @return [void]
    def structure_container(tag, attributes = {}, &block)
      return yield if !tagged? || !block

      tree = renderer.structure_tree
      tree.begin_element(tag, attributes)
      yield
      tree.end_element
    end

    # Mark content as an artifact (decorative, not read by screen readers).
    # Use for page numbers, decorative borders, backgrounds, watermarks.
    #
    # @param type [Symbol, nil] artifact type (:Pagination, :Layout,
    #   :Page, :Background)
    # @yield content to render as artifact
    # @return [void]
    def artifact(type: nil, &block)
      return yield if !tagged? || !block

      renderer.structure_tree.mark_artifact(artifact_type: type, &block)
    end

    # Render a heading at the specified level.
    #
    # @param level [Integer] heading level 1-6
    # @param content [String] heading text
    # @param options [Hash] options passed to `text()`
    # @return [void]
    def heading(level, content, options = {})
      tag = :"H#{level}"
      if tagged?
        structure(tag) { text(content, options) }
      else
        text(content, options)
      end
    end

    # Render text wrapped in a paragraph structure element.
    #
    # @param content [String, nil] text to render. If nil, yields a block.
    # @param options [Hash] options passed to `text()`
    # @yield optional block for complex paragraph content
    # @return [void]
    def paragraph(content = nil, options = {}, &block)
      if tagged?
        if block
          structure(:P, &block)
        else
          structure(:P) { text(content, options) }
        end
      elsif block
        yield
      else
        text(content, options)
      end
    end

    # Render an image wrapped in a Figure structure element with alt text.
    #
    # @param alt_text [String] alternative text for the image
    # @yield block that calls `image()` or other drawing methods
    # @return [void]
    def figure(alt_text:, &block)
      if tagged?
        structure(:Figure, Alt: alt_text, &block)
      else
        yield
      end
    end
  end
end
