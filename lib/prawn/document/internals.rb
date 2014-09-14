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

      delegate [ :ref, :ref!, :deref, :add_content,
                 :before_render, :on_page_create, :start_new_page, :page_count,
                 :go_to_page, :open_graphics_state, :close_graphics_state,
                 :save_graphics_state, :restore_graphics_state,
                 :graphic_stack, :graphic_state ] => :renderer

      # FIXME: This is a circular reference, because in theory Prawn should
      # be passing instances of renderer to PDF::Core::Page, but it's
      # passing Prawn::Document objects instead.
      #
      # A proper design would probably not require Prawn to directly instantiate
      # PDF::Core::Page objects at all!
      delegate [:compression_enabled?] => :renderer

      # FIXME: Another circular reference, because we mix in a module from
      # PDF::Core to provide destinations, which in theory should not
      # rely on a Prawn::Document object but is currently wired up that way.
      delegate [:names] => :renderer

      def renderer
        @renderer ||= PDF::Core::Renderer.new(state)
      end
    end
  end
end
