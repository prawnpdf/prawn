module Prawn
  class Document
    
    # Takes a current snapshot of the document's state, sufficient to
    # reconstruct it after it was amended.
    def take_snapshot
      {:page_content    => Marshal.load(Marshal.dump(page_content.data)),
       :page_content_id => @page_content,
       :current_page    => Marshal.load(Marshal.dump(current_page.data)),
       :current_page_id => @current_page,
       :page_kids       => @store.pages.data[:Kids].map{|kid| kid.identifier},
       # TODO: do dests need to be deep copied?
       :dests           => names.data[:Dests]}
    end

    def restore_snapshot(shot)
      # TODO: delete the old refs?? This is churning the old refs.
      @page_content = ref(shot[:page_content])
      @current_page = ref(shot[:current_page])
      # current_page still holds a Contents pointer to its old contents; fix that up
      current_page.data[:Contents] = page_content

      @store.pages.data[:Kids] = shot[:page_kids][0..-2].map{|id| @store[id]} + [current_page]
      @store.pages.data[:Count] = shot[:page_kids].size

      names.data[:Dests] = shot[:dests]
    end

  end
end
