# encoding: utf-8

# annotations.rb : Implements destination support for PDF
#
# Copyright November 2008, Jamis Buck. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
require 'prawn/name_tree'

module Prawn
  class Document
    module Destinations
      
      # The maximum number of children to fit into a single node in the Dests tree.
      NAME_TREE_CHILDREN_LIMIT = 20 #:nodoc:
      
      # The Dests name tree in the Name dictionary (see Prawn::Document::Internal#names).
      # This name tree is used to store named destinations (PDF spec 8.2.1).
      # (For more on name trees, see section 3.8.4 in the PDF spec.)
      #
      def dests
        names.data[:Dests] ||= ref!(Prawn::NameTree::Node.new(self, NAME_TREE_CHILDREN_LIMIT))
      end

      # Adds a new destination to the dests name tree (see #dests). The
      # +reference+ parameter will be converted into a Prawn::Reference if
      # it is not already one.
      #
      def add_dest(name, reference)
        reference = ref!(reference) unless reference.is_a?(Prawn::Reference)
        dests.data.add(name, reference)
      end

      # Return a Dest specification for a specific location (and optional zoom
      # level).
      #
      def dest_xyz(left, top, zoom=nil, page=current_page)
        [page, :XYZ, left, top, zoom]
      end

      # Return a Dest specification that will fit the given page into the
      # viewport.
      #
      def dest_fit(page=current_page)
        [page, :Fit]
      end

      # Return a Dest specification that will fit the given page horizontally
      # into the viewport, aligned vertically at the given top coordinate.
      #
      def dest_fit_horizontally(top, page=current_page)
        [page, :FitH, top]
      end

      # Return a Dest specification that will fit the given page vertically
      # into the viewport, aligned horizontally at the given left coordinate.
      #
      def dest_fit_vertically(left, page=current_page)
        [page, :FitV, left]
      end

      # Return a Dest specification that will fit the given rectangle into the
      # viewport, for the given page.
      #
      def dest_fit_rect(left, bottom, right, top, page=current_page)
        [page, :FitR, left, bottom, right, top]
      end

      # Return a Dest specfication that will fit the given page's bounding box
      # into the viewport.
      #
      def dest_fit_bounds(page=current_page)
        [page, :FitB]
      end

      # Same as #dest_fit_horizontally, but works on the page's bounding box
      # instead of the entire page.
      #
      def dest_fit_bounds_horizontally(top, page=current_page)
        [page, :FitBH, top]
      end

      # Same as #dest_fit_vertically, but works on the page's bounding box
      # instead of the entire page.
      #
      def dest_fit_bounds_vertically(left, page=current_page)
        [page, :FitBV, left]
      end
    end
  end
end
