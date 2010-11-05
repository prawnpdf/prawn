# encoding: utf-8
#
# Helper for organizing examples
#

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'prawn'
require 'prawn/security'
require 'prawn/layout'

require 'enumerator'

Prawn.debug = true

module Prawn
  
  class Example < Prawn::Document
    
    def load_package(package)
      package_file = File.expand_path(File.join(
                          File.dirname(__FILE__), package, "#{package}.rb"))
      
      data = File.read(package_file)
      eval extract_source(data)
    end
    
    def build_package(package, examples_outline)
      examples = flatten_examples_outline(examples_outline)

      title = "#{package.capitalize} Reference"
      text title, :size => 30

      first_page = page_number

      examples.each do |example|
        start_new_page

        example = "#{example}.rb"
        text example, :size => 20
        move_down 10

        load_example(package, example)
      end

      build_package_root_outline_section(title, first_page)
      build_package_outline(title, examples_outline, first_page + 1)
    end
    
    def flatten_examples_outline(examples_outline)
      examples_outline.map do |example_or_subsection|
        if Array === example_or_subsection
          flatten_examples_outline example_or_subsection.last
        else
          example_or_subsection
        end
      end.flatten
    end
    
    def build_package_root_outline_section(title, page)
      if outline.items.include? "Prawn by Example"
        
        outline.add_subsection_to "Prawn by Example" do 
          outline.section title, :destination => page
        end
      else
        outline.define do
          section title, :destination => page
        end
      end
    end
    
    def build_package_outline(title, examples_outline, current_page)
      examples_outline.each do |example_or_subsection|
        
        if Array === example_or_subsection
          
          outline.add_subsection_to title do 
            outline.section example_or_subsection.first,
                            :destination => current_page,
                            :closed => true
          end
          
          current_page = build_package_outline example_or_subsection.first,
                                               example_or_subsection.last,
                                               current_page
          
        else
          outline.add_subsection_to title do 
            outline.page :destination => current_page,
                :title => example_or_subsection.gsub("_", " ").capitalize
          end
          
          current_page += 1
        end
      end
      
      current_page
    end
  
    def load_example(package, example)
      example_file = File.expand_path(File.join(
                          File.dirname(__FILE__), package, example))
      
      data = File.read(example_file)
      example_source = extract_source(data)
  
      text extract_introduction_text(data), :inline_format => true
  
      bounding_box([bounds.left, cursor], :width => bounds.width) do
        font('Courier', :size => 11) do
          text example_source.gsub(' ', Prawn::Text::NBSP)
        end
      
        move_down 10
        dash(3)
        stroke_horizontal_line -36, bounds.width + 36
        undash
      end
    
      move_down 10
      eval example_source
    end
    
    def stroke_axis(options={})
      options = { :height => 350, :width => bounds.width.to_i }.merge(options)
      
      dash(1, :space => 4)
      stroke_horizontal_line -21, options[:width], :at => 0
      stroke_vertical_line -21, options[:height], :at => 0
      undash
      
      fill_circle_at [0, 0], :radius => 1
      (100..options[:width]).step(100).each do |point|
        fill_circle_at [point, 0], :radius => 1
        draw_text point, :at => [point-5, -10], :size => 7
      end

      (100..options[:height]).step(100).each do |point|
        fill_circle_at [0, point], :radius => 1
        draw_text point, :at => [-17, point-2], :size => 7
      end
    end
    
    def reset_drawing_settings
      self.line_width = 1
      self.cap_style  = :butt
      self.join_style = :miter
      undash
      fill_color "000000"
      stroke_color "000000"
    end

  private

    # Returns anything within the Example.generate block
    def extract_source(source)
      source.slice(/\w+\.generate.*? do(.*)end/m, 1) or source
    end
  
    # Returns the comments between the encoding declaration and the require
    def extract_introduction_text(source)
      intro = source.slice(/# encoding.*?\n(.*)require/m, 1)
      intro.gsub!(/\n# (?=\S)/m, ' ')
      intro.gsub!('#', '')
      intro.gsub!("\n", "\n\n")
      intro.rstrip!
      
      # Process the <code> tags
      intro.gsub!(/<code>([^<]+?)<\/code>/,
                  "<font name='Courier'>\\1<\/font>")
      
      intro
    end
  end

end
