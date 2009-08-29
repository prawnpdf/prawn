module Prawn
  class Document

    def checkpoint
      (@snapshots ||= []).push(take_snapshot)
    end

    def rollback
      snap = @snapshots.pop || raise("No checkpoint to rollback!")
      restore_snapshot(snap)
    end

    def commit
      @snapshots.pop || raise("No checkpoint to commit!")
    end

    protected
    
#     require 'pp'
    # Takes a current snapshot of the document's state, sufficient to
    # reconstruct it after it was amended.
    def take_snapshot
#       puts "  --- Snapshotting current page:"
#       pp current_page

#       puts "  --- Snapshotting page content:"
#       pp page_content

      {:page_content    => Marshal.load(Marshal.dump(page_content)),
       :page_content_id => @page_content,
       :current_page    => Marshal.load(Marshal.dump(current_page)),
       :current_page_id => @current_page,
       :page_kids       => @store.pages.data[:Kids].map{|kid| kid.identifier},
       # TODO: do dests need to be deep copied?
       :dests           => names.data[:Dests]}
    end

    def restore_snapshot(shot)
      # TODO: delete the old refs?? This is churning the old refs.
      @page_content = dup_ref(shot[:page_content])
      @current_page = dup_ref(shot[:current_page])

#       puts "  --- Rolled back current page:"
#       pp current_page

#       puts "  --- Rolled back page content:"
#       pp page_content

      # current_page still holds a Contents pointer to its old contents; fix that up
      current_page.data[:Contents] = page_content
      current_page.data[:Parent] = @store.pages

      @store.pages.data[:Kids] = shot[:page_kids][0..-2].map{|id| @store[id]} + [current_page]
      @store.pages.data[:Count] = shot[:page_kids].size

      names.data[:Dests] = shot[:dests]
    end

    def dup_ref(old_ref)
      r = ref!(old_ref.data)
      r << old_ref.stream if old_ref.stream
      r.identifier
    end

  end
end
