# encoding: utf-8

# text/formatted/rectangle.rb : Implements text boxes with formatted text
#
# This modification to Prawn was begun by Mike Blyth
# Prawn itself is copyright February 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Text
    module Formatted

  # 
  # Flow text in any number of columns with automatic continuing to next page
  # * uses entire bounds height and width unless margins are included in options
  # * always starts in first column regardless of current state of page
  # * uses formatted_text_box method but outputs raw text unless :inline_format is specified
  # Options include (default)
  # *    :columns => n (2)
  # *    :top_margin => n (0)
  # *    :bottom_margin => n (0)
  # *    :gutter => n (18)
  # * any other options are also passed to formatted_text_box so you can use :size, :style, or whatever.
  def flow_in_columns(text, options)
      # Get any options or use defaults
      gutter = options[:gutter] || 18
      columns = options[:columns] || 2
      top_margin = options[:top_margin] || 0
      bottom_margin = options[:bottom_margin] || 0
      # calculate column left edges and widths (all are same width)
      col_width = (bounds.width-(columns-1)*gutter)/columns
      col_left_edge = []
      0.upto(columns-1) do |x|
        col_left_edge << x*(col_width+gutter)
      end  

      # Initialize excess_text for setting text    
 	  # excess_text keeps what's left over after filling a given column
	  if text.class != Array			# already in formatted_text array?
        # convert to formatted_text array
		if options[:inline_format]
			text = Text::Formatted::Parser.to_array(text) 
		else
			text = [{:text=>"#{text}"}]  # just use the raw text if not :inline_format
		end
	  end
	  column_number = 0

      # now repeat cycle of fill a column, fill next column with leftover text, etc., 
      # ... going to next page after filling all the columns on current page
      until text.empty?
        text = formatted_text_box(text, {
          :width => col_width,
          :height => bounds.height-top_margin-bottom_margin,
          :overflow => :truncate,
          :at => [col_left_edge[column_number], bounds.top-top_margin],
        }.merge(options)) # merge any options sent as parameters, which could include :align, :style etc.
        column_number = (column_number+1) % columns
        start_new_page if column_number == 0 && !text.empty?
      end
  end #method

    end
  end
end
