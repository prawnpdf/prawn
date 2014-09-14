# encoding: utf-8
#
# internals.rb : Implements document internals for Prawn
#
# Copyright August 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "forwardable"

module Prawn
  class Document

    # This module exposes a few low-level PDF features for those who want
    # to extend Prawn's core functionality.  If you are not comfortable with
    # low level PDF functionality as defined by Adobe's specification, chances
    # are you won't need anything you find here.
    #
    # @private
    module Internals
      extend Forwardable

      delegate [ :ref, :ref!, :deref, :add_content, :names, :names?,
                 :before_render, :on_page_create, :start_new_page, :page_count,
                 :go_to_page, :finalize_all_page_contents, :min_version, :render,
                 :render_file, :render_header, :render_body, :render_xref,
                 :render_trailer, :open_graphics_state, :close_graphics_state,
                 :save_graphics_state, :compression_enabled?, :restore_graphics_state,
                 :graphic_stack, :graphic_state ] => :renderer

      def renderer
        @renderer ||= PDF::Core::Renderer.new(state)
      end
    end
  end
end
