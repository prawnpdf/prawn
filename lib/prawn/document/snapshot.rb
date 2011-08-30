# encoding: utf-8

# snapshot.rb : Implements transactional rendering for Prawn
#
# Copyright August 2009, Brad Ediger.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'delegate'

module Prawn
  class Document
    module Snapshot

      RollbackTransaction = Class.new(StandardError)

      # Call this within a +transaction+ block to roll back the transaction and
      # prevent any of its data from being rendered. You must reset the
      # y-position yourself if you have performed any drawing operations that
      # modify it.
      #
      def rollback
        raise RollbackTransaction
      end

      # Run a block of drawing operations, to be completed atomically. If
      # +rollback+ is called or a RollbackTransaction exception is raised
      # inside the block, all actions taken inside the block will be rolled
      # back (with the exception of y-position, which you must restore
      # yourself). 
      #
      # Returns true on success, or false if the transaction was rolled back.
      #
      def transaction
        snap = take_snapshot
        yield
        true
      rescue RollbackTransaction
        restore_snapshot(snap)
        false
      end

      private
      
      # Takes a current snapshot of the document's state, sufficient to
      # reconstruct it after it was amended.
      #
      def take_snapshot
        # current_page holds a ref to the Pages dictionary which grows
        # monotonically as data is added to the document, so we share that
        # between the old and new copies.
        {:page_content    => state.page.content.deep_copy,
         :current_page    => state.page.dictionary.deep_copy(share=[:Parent]),
         :bounds          => bounds.deep_copy,
         :page_number     => page_number,
         :page_kids       => state.store.pages.data[:Kids].map{|kid| kid.identifier},
         :dests           => names? && names.data[:Dests].deep_copy}
      end

      # Rolls the page state back to the state of the given snapshot.
      #
      def restore_snapshot(shot)
        page = state.page
        # Because these objects are referenced by identifier from the Pages
        # dictionary, we can't just restore them over the current refs in
        # page_content and current_page. We have to restore them over the old
        # ones.
        page.content = shot[:page_content].identifier
        page.content.replace shot[:page_content]

        page.dictionary = shot[:current_page].identifier
        page.dictionary.replace shot[:current_page]
        page.dictionary.data[:Contents] = page.content

        self.page_number = shot[:page_number]

        state.store.pages.data[:Kids] = shot[:page_kids].map{|id| state.store[id]}
        state.store.pages.data[:Count] = shot[:page_kids].size

        self.bounds = BoundingBox.restore_deep_copy(shot[:bounds], self)

        if shot[:dests]
          names.data[:Dests] = shot[:dests] 
        end
      end

    end
  end
end
