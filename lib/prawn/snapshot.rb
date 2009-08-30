require 'delegate'

module Prawn
  class Document

    RollbackTransaction = Class.new(StandardError)

    def transaction
      snap = take_snapshot
      yield
      true
    rescue RollbackTransaction
      restore_snapshot(snap)
      false
    end

    CannotGroupOnPage = Class.new(StandardError)

    def group_on_page(second_attempt=false)
      old_bounding_box = @bounding_box
      @bounding_box = SimpleDelegator.new(@bounding_box)

      def @bounding_box.move_past_bottom
        raise RollbackTransaction
      end

      success = transaction { yield }

      unless success
        raise CannotGroupOnPage if second_attempt
        start_new_page
        group_on_page(second_attempt=true) { yield }
      end 

      @bounding_box = old_bounding_box
    end

    protected
    
    # Takes a current snapshot of the document's state, sufficient to
    # reconstruct it after it was amended.
    def take_snapshot
      {:page_content    => Marshal.load(Marshal.dump(page_content)),
       :current_page    => Marshal.load(Marshal.dump(current_page)),
       :page_kids       => @store.pages.data[:Kids].map{|kid| kid.identifier},
       :dests           => Marshal.load(Marshal.dump(names.data[:Dests]))}
    end

    # Rolls the page state back to the state of the given snapshot.
    def restore_snapshot(shot)
      update_ref(page_content, shot[:page_content])
      update_ref(current_page, shot[:current_page])

      @store.pages.data[:Kids] = shot[:page_kids].map{|id| @store[id]}
      @store.pages.data[:Count] = shot[:page_kids].size

      names.data[:Dests] = shot[:dests]
    end

    def update_ref(copy_to, copy_from)
      copy_to.data = copy_from.data
      copy_to.stream = copy_from.stream
    end

  end
end
