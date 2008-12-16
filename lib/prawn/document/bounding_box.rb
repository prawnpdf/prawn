# encoding: utf-8

# bounding_box.rb : Implements a mechanism for shifting the coordinate space
#
# Copyright May 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    
    # A bounding box serves two important purposes:
    # * Provide bounds for flowing text, starting at a given point
    # * Translate the origin (0,0) for graphics primitives, for the purposes
    # of simplifying coordinate math.
    #
    # When flowing text, the usage of a bounding box is simple. Text will
    # begin at the point specified, flowing the width of the bounding box.
    # After the block exits, the cursor position will be moved to
    # the bottom of the bounding box (y - height). If flowing text exceeds
    # the height of the bounding box, the text will be continued on the next
    # page, starting again at the top-left corner of the bounding box.
    #
    #   pdf.bounding_box([100,500], :width => 100, :height => 300) do
    #     pdf.text "This text will flow in a very narrow box starting" +
    #      "from [100,500]. The pointer will then be moved to [100,200]" +
    #      "and return to the margin_box"
    #   end
    #
    # When translating coordinates, the idea is to allow the user to draw
    # relative to the origin, and then translate their drawing to a specified
    # area of the document, rather than adjust all their drawing coordinates
    # to match this new region.
    #
    # Take for example two triangles which share one point, drawn from the
    # origin:
    #
    #   pdf.polygon [0,250], [0,0], [150,100]
    #   pdf.polygon [100,0], [150,100], [200,0]
    #
    # It would be easy enough to translate these triangles to another point,
    # e.g [200,200]
    #
    #   pdf.polygon [200,450], [200,200], [350,300]
    #   pdf.polygon [300,200], [350,300], [400,200]
    #
    # However, each time you want to move the drawing, you'd need to alter
    # every point in the drawing calls, which as you might imagine, can become
    # tedious.
    #
    # If instead, we think of the drawing as being bounded by a box, we can
    # see that the image is 200 points wide by 250 points tall.
    #
    # To translate it to a new origin, we simply select a point at (x,y+height)
    #
    # Using the [200,200] example:
    #
    #   pdf.bounding_box([200,450], :width => 200, :height => 250) do
    #     pdf.polygon [0,250], [0,0], [150,100]
    #     pdf.polygon [100,0], [150,100], [200,0]
    #   end
    #
    # Notice that the drawing is still relative to the origin. If we want to
    # move this drawing around the document, we simply need to recalculate the
    # top-left corner of the rectangular bounding-box, and all of our graphics
    # calls remain unmodified.
    # 
    # By default, bounding boxes are specified relative to the document's 
    # margin_box (which is itself a bounding box).  You can also nest bounding
    # boxes, allowing you to build components which are relative to each other
    #
    # pdf.bouding_box([200,450], :width => 200, :height => 250) do
    #   pdf.bounding_box([50,200], :width => 50, :height => 50) do
    #     # a 50x50 bounding box that starts 50 pixels left and 50 pixels down 
    #     # the parent bounding box.
    #   end
    # end
    #
    # If you wish to position the bounding boxes at absolute coordinates rather
    # than relative to the margins or other bounding boxes, you can use canvas()
    #
    #   pdf.canvas do
    #     pdf.bounding_box([200,450], :width => 200, :height => 250) do
    #       # positioned at 'real' (200,450)
    #     end
    #   end
    #
    # Of course, if you use canvas, you will be responsible for ensuring that
    # you remain within the printable area of your document.
    #
    def bounding_box(*args, &block)    
      init_bounding_box(block) do |_|
        translate!(args[0])     
        @bounding_box = BoundingBox.new(self, *args)   
      end
    end 
    
        
    # A LazyBoundingBox is simply a BoundingBox with an action tied to it to be 
    # executed later.  The lazy_bounding_box method takes the same arguments as
    # bounding_box, but returns a LazyBoundingBox object instead of executing
    # the code block directly.
    #
    # You can then call LazyBoundingBox#draw at any time (or multiple times if 
    # you wish), and the contents of the block will then be run. This can be
    # useful for assembling repeating page elements or reusable components.
    #
    #  file = "lazy_bounding_boxes.pdf"
    #  Prawn::Document.generate(file, :skip_page_creation => true) do                    
    #    point = [bounds.right-50, bounds.bottom + 25]
    #    page_counter = lazy_bounding_box(point, :width => 50) do   
    #      text "Page: #{page_count}"
    #    end 
    #
    #    10.times do         
    #     start_new_page
    #      text "Some text"  
    #      page_counter.draw
    #    end
    #  end
    #
    def lazy_bounding_box(*args,&block)
      translate!(args[0])  
      box = LazyBoundingBox.new(self,*args)
      box.action(&block)
      return box 
    end
    
    # A shortcut to produce a bounding box which is mapped to the document's
    # absolute coordinates, regardless of how things are nested or margin sizes.
    #
    #   pdf.canvas do
    #     pdf.line pdf.bounds.bottom_left, pdf.bounds.top_right
    #   end
    #
    def canvas(&block)     
      init_bounding_box(block, :hold_position => true) do |_|
        @bounding_box = BoundingBox.new(self, [0,page_dimensions[3]], 
          :width => page_dimensions[2], 
          :height => page_dimensions[3] 
        ) 
      end
    end  
    
    # A bounding box with the same dimensions of its parents, minus a margin
    # on all sides
    #
    def padded_box(margin, &block)
      bounding_box [bounds.left + margin, bounds.top - margin],
        :width  => bounds.width - (margin * 2), 
        :height => bounds.height - (margin * 2), &block 
    end
       
    # A header is a LazyBoundingBox drawn relative to the margins that can be
    # repeated on every page of the document.
    #
    # Unless <tt>:width</tt> or <tt>:height</tt> are specified, the margin_box
    # width and height are used.   
    #
    #   header margin_box.top_left do 
    #    text "Here's My Fancy Header", :size => 25, :align => :center   
    #    stroke_horizontal_rule
    #  end
    #
    def header(top_left,options={},&block)   
      @header = repeating_page_element(top_left,options,&block)
    end
        
    # A footer is a LazyBoundingBox drawn relative to the margins that can be
    # repeated on every page of the document.
    #
    # Unless <tt>:width</tt> or <tt>:height</tt> are specified, the margin_box
    # width and height are used.
    #
    #   footer [margin_box.left, margin_box.bottom + 25] do
    #     stroke_horizontal_rule
    #     text "And here's a sexy footer", :size => 16
    #   end    
    #
    def footer(top_left,options={},&block)       
      @footer = repeating_page_element(top_left,options,&block)
    end
    
    private
    
    def init_bounding_box(user_block, options={}, &init_block)
      parent_box = @bounding_box       

      init_block.call(parent_box)     

      self.y = @bounding_box.absolute_top       
      user_block.call   
      self.y = @bounding_box.absolute_bottom unless options[:hold_position]

      @bounding_box = parent_box 
    end   
    
    def repeating_page_element(top_left,options={},&block)   
      r = LazyBoundingBox.new(self, translate(top_left),
        :width  => options[:width]  || margin_box.width, 
        :height => options[:height] || margin_box.height )
      r.action(&block)
      return r
    end  
 
    class BoundingBox
      
      def initialize(parent, point, options={}) #:nodoc:   
        @parent = parent
        @x, @y = point
        @width, @height = options[:width], options[:height]
      end     
      
      # The translated origin (x,y-height) which describes the location
      # of the bottom left corner of the bounding box
      #
      def anchor
        [@x, @y - height]
      end
      
      # Relative left x-coordinate of the bounding box. (Always 0)
      #
      def left
        0
      end
      
      # Relative right x-coordinate of the bounding box. (Equal to the box width)
      #
      def right
        @width
      end
      
      # Relative top y-coordinate of the bounding box. (Equal to the box height)
      #
      def top
        height
      end
      
      # Relative bottom y-coordinate of the bounding box (Always 0)
      #
      def bottom
        0
      end

      # Relative top-left point of the bounding_box
      #
      def top_left
        [left,top]
      end

      # Relative top-right point of the bounding box
      #
      def top_right
        [right,top]
      end

      # Relative bottom-right point of the bounding box
      #
      def bottom_right
        [right,bottom]
      end

      # Relative bottom-left point of the bounding box
      #
      def bottom_left
        [left,bottom]
      end
      
      # Absolute left x-coordinate of the bounding box
      #
      def absolute_left
        @x
      end
      
      # Absolute right x-coordinate of the bounding box
      #
      def absolute_right
        @x + width
      end
      
      # Absolute top y-coordinate of the bounding box
      #
      def absolute_top
        @y
      end
      
      # Absolute bottom y-coordinate of the bottom box
      #
      def absolute_bottom
        @y - height
      end

      # Absolute top-left point of the bounding box
      #
      def absolute_top_left
        [absolute_left, absolute_top]
      end

      # Absolute top-right point of the bounding box
      #
      def absolute_top_right
        [absolute_right, absolute_top]
      end

      # Absolute bottom-left point of the bounding box
      #
      def absolute_bottom_left
        [absolute_left, absolute_bottom]
      end

      # Absolute bottom-left point of the bounding box
      #
      def absolute_bottom_right
        [absolute_right, absolute_bottom]
      end
      
      # Width of the bounding box
      #
      def width
        @width
      end
      
      # Height of the bounding box.  If the box is 'stretchy' (unspecified
      # height attribute), height is calculated as the distance from the top of
      # the box to the current drawing position.
      #
      def height  
        @height || absolute_top - @parent.y
      end    
       
      # Returns +false+ when the box has a defined height, +true+ when the height
      # is being calculated on the fly based on the current vertical position.
      #
      def stretchy?
        !@height 
      end
      
    end    
       
    class LazyBoundingBox < BoundingBox
       
       # Defines the block to be executed by LazyBoundingBox#draw. 
       # Usually, this will be used via a higher level interface.  
       # See the documentation for Document#lazy_bounding_box, Document#header,
       # and Document#footer
       #
       def action(&block)
         @action = block
       end
       
       # Sets Document#bounds to use the LazyBoundingBox for its bounds,
       # runs the block specified by LazyBoundingBox#action,
       # and then restores the original bounds of the document.
       #
       def draw
         @parent.mask(:y) do  
           parent_box = @parent.bounds  
           @parent.bounds = self    
           @parent.y = absolute_top
           @action.call   
           @parent.bounds = parent_box
         end
       end

    end
    
  end
end
