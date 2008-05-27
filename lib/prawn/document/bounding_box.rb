module Prawn 
  class Document   
    
    # A bounding box serves two important purposes:
    #    * Provide bounds for flowing text, starting at a given point
    #    * Translate the origin (0,0) for graphics primitives, for the purposes
    #      of simplifying coordinate math.
    #
    # When flowing text, the usage of a bounding box is simple. Text will
    # begin at the point specified, flowing the width of the bounding box.
    # After the block exits, the text drawing position will be moved to 
    # the bottom of the bounding box (y - height).  Currently, Prawn allows
    # text to overflow the bottom border of the bounding box, so it is up to
    # the user to ensure the text provided will fit within the height of the
    # bounding box.
    #
    #    pdf.bounding_box([100,500], :width => 100, :height => 300) do
    #      pdf.text "This text will flow in a very narrow box starting" +
    #       "from [100,500].  The pointer will then be moved to [100,200]" +
    #       "and return to the margin_box"
    #    end
    #    
    # When translating coordinates, the idea is to allow the user to draw 
    # relative to the origin, and then translate their drawing to a specified
    # area of the document, rather than adjust all their drawing coordinates
    # to match this new region.
    #
    # Take for example two triangles which share one point, drawn from the
    # origin:
    #
    #    pdf.polygon [0,250], [0,0], [150,100]
    #    pdf.polygon [100,0], [150,100], [200,0]
    #
    # It would be easy enough to translate these triangles to another point,
    # e.g [200,200]
    #
    #    pdf.polygon [200,450], [200,200], [350,300]
    #    pdf.polygon [300,200], [350,300], [400,200]
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
    #    pdf.bounding_box([200,450], :width => 200, :height => 250) do
    #      pdf.polygon [0,250], [0,0], [150,100] 
    #      pdf.polygon [100,0], [150,100], [200,0]
    #    end
    #
    # Notice that the drawing is still relative to the origin.  If we want to
    # move this drawing around the document, we simply need to recalculate the
    # top-left corner of the rectangular bounding-box, and all of our graphics
    # calls remain unmodified.
    #
    def bounding_box(*args, &block)
      @bounding_box = BoundingBox.new(self, *args)
      self.y = @bounding_box.absolute_top
      
      block.call
      
      self.y = @bounding_box.absolute_bottom
      @bounding_box = @margin_box
    end
    
    class BoundingBox
      
      def initialize(parent, point, options={}) #:nodoc:
        @parent = parent
        @x, @y = point
        @width, @height = options[:width], options[:height]
      end
       
      # The translated origin (x,y-height) which describes the location
      # of the bottom left corner of the bounding box in absolute terms.
      def anchor
        [@x, @y - height]
      end
      
      # Relative left x-coordinate of the bounding box. (Always 0)
      def left
        0
      end
      
      # Relative right x-coordinate of the bounding box. (Equal to the box width)
      def right
        @width
      end
      
      # Relative top y-coordinate of the bounding box. (Equal to the box height)
      def top
        height
      end
      
      # Relative bottom y-coordinate of the bounding box (Always 0)
      def bottom
        0
      end
      
      # Absolute left x-coordinate of the bounding box
      def absolute_left
        @x
      end
      
      # Absolute right x-coordinate of the bounding box
      def absolute_right
        @x + width
      end
      
      # Absolute top y-coordinate of the bounding box
      def absolute_top
        @y
      end
      
      # Absolute bottom y-coordinate of the bottom box
      def absolute_bottom
        @y - height
      end
      
      def width
        @width
      end
      
      def height
        if @height.nil?
          absolute_top - @parent.y
        else
          @height
        end
      end
    end
  end
end
