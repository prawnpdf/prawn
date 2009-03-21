puts "REQUIERED #{__FILE__}"

module Prawn
  class Document
    def define_grid(options = {})
      @grid = Grid.new(self, options)
    end
  
    def grid(*args)
      @boxes ||= {}
      @boxes[args] ||= if args.empty?
        @grid
      else
        g1, g2 = args
        if g1.class == Array && g2.class == Array && g1.length == 2 && g2.length == 2
          multi_box(single_box(*g1), single_box(*g2))
        else
          single_box(g1, g2)
        end
      end
    end
  
    class Grid
      attr_reader :pdf, :columns, :rows, :gutter
    
      def initialize(pdf, options = {})
        Prawn.verify_options([:columns, :rows, :gutter], options)
      
        @pdf = pdf
        @columns = options[:columns]
        @rows = options[:rows]
        @gutter = options[:gutter].to_f
      end

      def column_width
        @column_width ||= subdivide(pdf.bounds.width, columns)
      end
    
      def row_height
       @row_height ||= subdivide(pdf.bounds.height, rows)
      end

      def show_all(color = "CCCCCC")
        self.rows.times do |i|
          self.columns.times do |j|
            pdf.grid(i,j).show(color)
          end
        end
      end

      private
      def subdivide(total, num)
        (total.to_f - (gutter * (num - 1).to_f)) / num.to_f
      end
    end
  
    class Box
      attr_reader :pdf
    
      def initialize(pdf, i, j)
        @pdf = pdf
        @i = i
        @j = j
      end
    
      def name
        "#{@i.to_s},#{@j.to_s}"
      end
    
      def total_height
        pdf.bounds.height.to_f
      end
    
      def width
        grid.column_width.to_f
      end
    
      def height
        grid.row_height.to_f
      end
    
      def gutter
        grid.gutter.to_f
      end
    
      def left
        @left ||= (width + gutter) * @j.to_f
      end
    
      def right
        @right ||= left + width
      end
    
      def top
        @top ||= total_height - ((height + gutter) * @i.to_f)
      end
    
      def bottom
        @bottom ||= top - height
      end
    
      def top_left
        [left, top]
      end
    
      def top_right
        [right, top]
      end
    
      def bottom_left
        [left, bottom]
      end
    
      def bottom_right
        [right, bottom]
      end
    
      def bounding_box(&blk)
        pdf.bounding_box(top_left, :width => width, :height => height, &blk)
      end
    
      def show(grid_color = "CCCCCC")
        self.bounding_box do
          pdf.stroke_color = grid_color
          pdf.text self.name
          pdf.stroke_bounds
        end
      end
    
      private
      def grid
        pdf.grid
      end
    end
  
    class MultiBox < Box
      def initialize(pdf, b1, b2)
        @pdf = pdf
        @bs = [b1, b2]
      end
    
      def name
        @bs.map {|b| b.name}.join(":")
      end
    
      def total_height
        @bs[0].total_height
      end

      def width
        right_box.right - left_box.left
      end
    
      def height
        top_box.top - bottom_box.bottom
      end
    
      def gutter
        @bs[0].gutter
      end
    
      def left
        left_box.left
      end
    
      def right
        right_box.right
      end
    
      def top
        top_box.top
      end
    
      def bottom
        bottom_box.bottom
      end
    
      private
      def left_box
        @left_box ||= @bs.min {|a,b| a.left <=> b.left}
      end
    
      def right_box
        @right_box ||= @bs.max {|a,b| a.right <=> b.right}
      end
    
      def top_box
        @top_box ||= @bs.max {|a,b| a.top <=> b.top}
      end
    
      def bottom_box
        @bottom_box ||= @bs.min {|a,b| a.bottom <=> b.bottom}
      end
    end
  
    private
    def single_box(i, j)
      Box.new(self, i, j)
    end
  
    def multi_box(b1, b2)
      MultiBox.new(self, b1, b2)
    end
  end
end
