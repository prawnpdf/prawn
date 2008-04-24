module Prawn
  class Document    
    
    def initialize
       @objects = []
       @info    = ref(:Creator => "Prawn", :Producer => "Prawn")
       @pages   = ref(:Type => :Pages, :Count => 0, :Kids => [])
       @root    = ref(:Type => :Catalog, :Pages => @pages)  
       start_new_page
     end  
   
     def start_new_page
       finish_page_content if @page_content
     
       @current_page = ref(:Type     => :Page, 
                           :Parent   => @pages, 
                           :MediaBox => [0, 0, 595.28, 841.89], 
                           :Contents => @page_content) 
     
       @pages.data[:Kids] << @current_page
       @pages.data[:Count] += 1 
     
       @page_content = ref(:Length => 0)   
       add_content "q"   
    end
       
    private
   
    def ref(data)
      @objects << Prawn::Reference.new(data)
    end  
   
    def add_content(str)
     @page_content << str << "\n"
    end  
    
    def finish_page_content
      add_content "Q"
      @page_content.data[:Length] = @cur_content.stream.size
    end
    
  end
end