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
  
  # The Prawn::Example class holds all the helper methods used to generate the
  # Prawn by example manual.
  #
  # The overall structure is to have single example files grouped by package
  # folders. Each package has a package builder file (with the same name as the
  # package folder) that defines the inner structure of subsections and
  # examples. The manual is then built by loading all the packages and some
  # standalone pages.
  #
  # To see one of the examples check manual/basic_concepts/cursor.rb
  #
  # To see one of the package builders check
  # manual/basic_concepts/basic_concepts.rb
  #
  # To see how the manual is built check manual/manual/manual.rb (Yes that's a
  # whole load of manuals)
  #
  class Example < Prawn::Document

    # Loads a package. Used on the manual.
    #
    def load_package(package)
      load_file(package, package)
    end
    
    # Loads a page with outline support. Used on the manual.
    #
    def load_page(page, page_name = nil)
      load_file("manual", page)

      outline.define do
        section(page_name || page.capitalize, :destination => page_number)
      end
    end

    # Opens a file in a given package and evals the source
    #
    def load_file(package, file)
      start_new_page
      data = read_file(package, "#{file}.rb")
      eval extract_generate_block(data)
    end
    
    # Create a package cover and load the examples provided in examples_outline
    # with outline support. Accepts an optional block to be used as the cover
    # content. Used by the package files.
    #
    def build_package(package, examples_outline, &block)
      title = package.gsub("_", " ").capitalize
      header(title)
      
      if block_given?
        instance_eval(&block)
      end

      outline.define do
        section(title, :destination => page_number, :closed => true)
      end
      
      build_package_examples(package, title, examples_outline)
    end
    
    # Recursively iterates through the examples subsections or pages according
    # to the examples_outline.
    #
    def build_package_examples(package, title, examples_outline)
      examples_outline.each do |example_or_subsection|
        
        case example_or_subsection
        when Array
          
          outline.add_subsection_to(title) do 
            outline.section(example_or_subsection.first, :closed => true)
          end
          
          build_package_examples(package,
                                 example_or_subsection.first,
                                 example_or_subsection.last)
          
        when Hash
          example = example_or_subsection.delete(:name)
          load_example(package, "#{example}.rb", example_or_subsection)
          
          outline.add_subsection_to(title) do 
            outline.page(:destination => page_number,
                         :title => example.gsub("_", " ").capitalize)
          end
        
        else
          initial_page = page_number + 1
          load_example(package, "#{example_or_subsection}.rb")
          
          outline.add_subsection_to(title) do 
            outline.page(:destination => initial_page,
                    :title => example_or_subsection.gsub("_", " ").capitalize)
          end
        end
      end
    end
  
    # Starts a new page to load an example from a given package. Renders an
    # introductory text and the example source. Available boolean options are:
    # 
    # <tt>:eval_source</tt>:: Evals the example source code (default: true)
    # <tt>:full_source</tt>:: Extract the full source code when true. Extract
    # only the code between the generate block when false (default: false)
    #
    def load_example(package, example, options={})
      options = { :eval_source => true,
                  :full_source => false
                }.merge(options)
      
      data = read_file(package, example)
      
      if options[:full_source]
        example_source = extract_full_source(data)
      else  
        example_source = extract_generate_block(data)
      end
      
      start_new_page
      
      text("<color rgb='999999'>#{package}/</color>#{example}",
           :size => 20, :inline_format => true)
      move_down 10
  
      text(extract_introduction_text(data), :inline_format => true)

      kai_file = "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
      font_families["Kai"] = {
        :normal => { :file => kai_file, :font => "Kai" }
      }
      dejavu_file = "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
      font_families["DejaVu"] = {
        :normal => { :file => dejavu_file, :font => "DejaVu" }
      }

      font('Courier', :size => 11) do
        text(example_source.gsub(' ', Prawn::Text::NBSP),
             :fallback_fonts => ["DejaVu", "Kai"])
      end
      
      if options[:eval_source]
        move_down 10
        dash(3)
        stroke_horizontal_line(-36, bounds.width + 36)
        undash
      
        move_down 10
        begin
          eval example_source
        rescue
          puts example_source
        end
      end
    end
    
    # Returns the data read from a file in a given package
    #
    def read_file(package, file)
      data = File.read(File.expand_path(File.join(
        File.dirname(__FILE__), package, file)))

      # XXX If we ever have manual files with source encodings other than
      # UTF-8, we will need to fix this to work on Ruby 1.9.
      if data.respond_to?(:encode!)
        data.encode!("UTF-8")
      end
      data
    end
    
    # Render a page header. Used on the manual lone pages and package
    # introductory pages
    #
    def header(str)
      move_down 40
      text(str, :size => 25, :style => :bold)
      stroke_horizontal_rule
      move_down 30
    end
    
    # Render the arguments as a bulleted list. Used on the manual package
    # introductory pages
    #
    def list(*items)
      move_down 20
      
      items.each do |li|
        float { text "•" }
        indent(10) do
          text li.gsub(/\s+/," "), 
            :inline_format => true,
            :leading       => 2
        end

        move_down 10
      end
    end
    
    # Draws X and Y axis rulers beginning at the margin box origin. Used on
    # examples.
    #
    def stroke_axis(options={})
      options = { :height => (cursor - 20).to_i,
                  :width => bounds.width.to_i
                }.merge(options)
      
      dash(1, :space => 4)
      stroke_horizontal_line(-21, options[:width], :at => 0)
      stroke_vertical_line(-21, options[:height], :at => 0)
      undash
      
      fill_circle [0, 0], 1
      
      (100..options[:width]).step(100) do |point|
        fill_circle [point, 0], 1
        draw_text point, :at => [point-5, -10], :size => 7
      end

      (100..options[:height]).step(100) do |point|
        fill_circle [0, point], 1
        draw_text point, :at => [-17, point-2], :size => 7
      end
    end
    
    # Reset some of the drawing settings to their defaults. Used on examples.
    #
    def reset_drawing_settings
      self.line_width = 1
      self.cap_style  = :butt
      self.join_style = :miter
      undash
      fill_color "000000"
      stroke_color "000000"
    end

  private

    # Retrieve the source code by excluding initial comments and require calls
    #
    def extract_full_source(source)
      source.gsub(/# encoding.*?\n.*require.*?\n\n/m, "\n")
    end
    
    # Retrieve the code inside the generate block
    #
    def extract_generate_block(source)
      source.slice(/\w+\.generate.*? do(.*)end/m, 1) or source
    end
  
    # Retrieve the comments between the encoding declaration and the require
    # call for example_helper.rb
    #
    # Then removes the '#' signs and reflows the line breaks
    #
    def extract_introduction_text(source)
      intro = source.slice(/# encoding.*?\n(.*)require File\.expand_path/m, 1)
      intro.gsub!(/\n# (?=\S)/m, ' ')
      intro.gsub!(/^#/, '')
      intro.gsub!("\n", "\n\n")
      intro.rstrip!
      
      # Process the <code> tags
      intro.gsub!(/<code>([^<]+?)<\/code>/,
                  "<font name='Courier'>\\1<\/font>")
      
      # Process the links
      intro.gsub!(/(https?:\/\/\S+)/,
                  "<link href=\"\\1\">\\1</link>")
      
      intro
    end
  end

end
