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

      delegate PDF::Core::Renderer.instance_methods(false) => :renderer

      # FIXME: This is a patch over PDF::Core that should not need to exist.
      def finalize_all_page_contents
        (1..page_count).each do |i|
          go_to_page i
          repeaters.each { |r| r.run(i) }
          while graphic_stack.present?
            restore_graphics_state
          end
          state.page.finalize
        end
      end

      def renderer
        @renderer ||= PDF::Core::Renderer.new(state)
      end
    end
  end
end
