# encoding: utf-8
#
# Helper for organizing examples
#

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'prawn'
require 'prawn/security'
require 'prawn/layout'

require 'enumerator'

require File.expand_path(File.join(File.dirname(__FILE__), 'example_file'))
require File.expand_path(File.join(File.dirname(__FILE__), 'example_section'))
require File.expand_path(File.join(File.dirname(__FILE__), 'example_package'))
require File.expand_path(File.join(File.dirname(__FILE__), 'syntax_highlight'))

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

    # Values used for the manual design:

    # This is the default value for the margin box
    #
    BOX_MARGIN   = 36

    # Additional indentation to keep the line measure with a reasonable size
    #
    INNER_MARGIN = 30

    # Vertical Rhythm settings
    #
    RHYTHM  = 10
    LEADING = 2

    # Colors
    #
    BLACK      = "000000"
    LIGHT_GRAY = "F2F2F2"
    GRAY       = "DDDDDD"
    DARK_GRAY  = "333333"
    BROWN      = "A4441C"
    ORANGE     = "F28157"
    LIGHT_GOLD = "FBFBBE"
    DARK_GOLD  = "EBE389"
    BLUE       = "0000D0"

    # Used to generate the url for the example files
    #
    MANUAL_URL = "http://github.com/prawnpdf/prawn/tree/master/manual"


    # Loads a package. Used on the manual.
    #
    def load_package(package)
      load_file(package, package)
    end

    # Loads a page with outline support. Used on the manual.
    #
    def load_page(page)
      load_file("manual", page)

      outline.define do
        section(page.gsub("_", " ").capitalize, :destination => page_number)
      end
    end

    # Opens a file in a given package and evals the source
    #
    def load_file(package, file)
      start_new_page
      example = ExampleFile.new(package, "#{file}.rb")
      eval example.generate_block_source
    end


    # Creates a new ExamplePackage object and yields it to a block in order for
    # it to be populated with examples, sections and some introduction text.
    # Used on the package files.
    #
    def package(package, &block)
      ep = ExamplePackage.new(package)
      ep.instance_eval(&block)
      ep.render(self)
    end

    # Renders an ExamplePackage cover page.
    #
    # Starts a new page and renders the package introduction text.
    #
    def render_package_cover(package)
      header(package.name)
      instance_eval &(package.intro_block)

      outline.define do
        section(package.name, :destination => page_number, :closed => true)
      end
    end

    # Add the ExampleSection to the document outline within the appropriate
    # package.
    #
    def render_section(section)
      outline.add_subsection_to(section.package_name) do
        outline.section(section.name, :closed => true)
      end
    end

    # Renders an ExampleFile.
    #
    # Starts a new page and renders an introductory text, the example source and
    # evaluates the example source inline whenever that is appropriate according
    # to the ExampleFile directives.
    #
    def render_example(example)
      start_new_page

      outline.add_subsection_to(example.parent_name) do
        outline.page(:destination => page_number, :title => example.name)
      end

      example_header(example.parent_folder_name, example.filename)

      prose(example.introduction_text)

      code(example.source)

      if example.eval?
        eval_code(example.source)
      else
        source_link(example)
      end

      reset_settings
    end

    # Render the example header. Used on the example pages of the manual
    #
    def example_header(package, example)
      header_box do
        register_fonts
        font('DejaVu', :size => 18) do
          formatted_text([ { :text => package, :color => BROWN  },
                           { :text => "/",     :color => BROWN  },
                           { :text => example, :color => ORANGE }
                         ], :valign => :center)
        end
      end
    end

    # Register fonts used on the manual
    #
    def register_fonts
      kai_file = "#{Prawn::DATADIR}/fonts/gkai00mp.ttf"
      font_families["Kai"] = {
        :normal => { :file => kai_file, :font => "Kai" }
      }

      dejavu_file = "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
      font_families["DejaVu"] = {
        :normal => { :file => dejavu_file, :font => "DejaVu" }
      }
    end

    # Render a block of text after processing code tags and URLs to be used with
    # the inline_format option.
    #
    # Used on the introducory text for example pages of the manual and on
    # package pages intro
    #
    def prose(str)

      # Process the <code> tags
      str.gsub!(/<code>([^<]+?)<\/code>/,
          "<font name='Courier'><b>\\1<\/b><\/font>")

      # Process the links
      str.gsub!(/(https?:\/\/\S+)/,
                  "<color rgb='#{BLUE}'><link href=\"\\1\">\\1</link></color>")

      inner_box do
        font("Helvetica", :size => 11) do
          str.split(/\n\n+/).each do |paragraph|

            text(paragraph.gsub(/\s+/," "),
                 :align         => :justify,
                 :inline_format => true,
                 :leading       => LEADING,
                 :color         => DARK_GRAY)

            move_down(RHYTHM)
          end
        end
      end

      move_down(RHYTHM)
    end

    # Render a code block. Used on the example pages of the manual
    #
    def code(str)
      pre_text = str.gsub(' ', Prawn::Text::NBSP)
      pre_text = ::CodeRay.scan(pre_text, :ruby).to_prawn

      font('Courier', :size => 9.5) do
        colored_box(pre_text, :fill_color => DARK_GRAY)
      end
    end

    # Renders a dashed line and evaluates the code inline
    #
    def eval_code(source)
      move_down(RHYTHM)

      dash(3)
      stroke_color(BROWN)
      stroke_horizontal_line(-BOX_MARGIN, bounds.width + BOX_MARGIN)
      stroke_color(BLACK)
      undash

      move_down(RHYTHM*3)
      begin
        eval(source)
      rescue => e
        puts "Error evaluating example: #{e.message}"
        puts
        puts "---- Source: ----"
        puts source
      end
    end

    # Renders a box with the link for the example file
    #
    def source_link(example)
      url = "#{MANUAL_URL}/#{example.parent_folder_name}/#{example.filename}"

      reason = [{ :text  => "This code snippet was not evaluated inline. " +
                            "You may see its output by running the " +
                            "example file located here:\n",
                  :color => DARK_GRAY },

                { :text   => url,
                  :color  => BLUE,
                  :link   => url}
               ]

      font('Helvetica', :size => 9) do
        colored_box(reason,
                    :fill_color   => LIGHT_GOLD,
                    :stroke_color => DARK_GOLD,
                    :leading      => LEADING*3)
      end
    end

    # Render a page header. Used on the manual lone pages and package
    # introductory pages
    #
    def header(str)
      header_box do
        register_fonts
        font('DejaVu', :size => 24) do
          text(str, :color  => BROWN, :valign => :center)
        end
      end
    end

    # Render the arguments as a bulleted list. Used on the manual package
    # introductory pages
    #
    def list(*items)
      move_up(RHYTHM)

      inner_box do
        font("Helvetica", :size => 11) do
          items.each do |li|
            float { text("•", :color => DARK_GRAY) }
            indent(RHYTHM) do
              text(li.gsub(/\s+/," "),
                   :inline_format => true,
                   :color         => DARK_GRAY,
                   :leading       => LEADING)
            end

            move_down(RHYTHM)
          end
        end
      end
    end

    # Renders the page-wide headers
    #
    def header_box(&block)
      bounding_box([-bounds.absolute_left, cursor + BOX_MARGIN],
                   :width  => bounds.absolute_left + bounds.absolute_right,
                   :height => BOX_MARGIN*2 + RHYTHM*2) do

        fill_color LIGHT_GRAY
        fill_rectangle([bounds.left, bounds.top],
                        bounds.right,
                        bounds.top - bounds.bottom)
        fill_color BLACK

        indent(BOX_MARGIN + INNER_MARGIN, &block)
      end

      stroke_color GRAY
      stroke_horizontal_line(-BOX_MARGIN, bounds.width + BOX_MARGIN, :at => cursor)
      stroke_color BLACK

      move_down(RHYTHM*3)
    end

    # Renders a Bounding Box for the inner margin
    #
    def inner_box(&block)
      bounding_box([INNER_MARGIN, cursor],
                   :width => bounds.width - INNER_MARGIN*2,
                   &block)
    end

    # Renders a Bounding Box with some background color and the formatted text
    # inside it
    #
    def colored_box(box_text, options={})
      options = { :fill_color   => DARK_GRAY,
                  :stroke_color => nil,
                  :text_color   => LIGHT_GRAY,
                  :leading      => LEADING
                }.merge(options)

      register_fonts
      text_options = { :leading        => options[:leading],
                       :fallback_fonts => ["DejaVu", "Kai"]
                     }

      box_height = height_of_formatted(box_text, text_options)

      bounding_box([INNER_MARGIN + RHYTHM, cursor],
                   :width => bounds.width - (INNER_MARGIN+RHYTHM)*2) do

        fill_color   options[:fill_color]
        stroke_color options[:stroke_color] || options[:fill_color]
        fill_and_stroke_rounded_rectangle(
            [bounds.left - RHYTHM, cursor],
            bounds.left + bounds.right + RHYTHM*2,
            box_height + RHYTHM*2,
            5
        )
        fill_color   BLACK
        stroke_color BLACK

        pad(RHYTHM) do
          formatted_text(box_text, text_options)
        end
      end

      move_down(RHYTHM*2)
    end

    # Draws X and Y axis rulers beginning at the margin box origin. Used on
    # examples.
    #
    def stroke_axis(options={})
      super({:height => (cursor - 20).to_i}.merge(options))
    end

    # Reset some of the Prawn settings including graphics and text to their
    # defaults.
    #
    # Used after rendering examples so that each new example starts with a clean
    # slate.
    #
    def reset_settings

      # Text settings
      font("Helvetica", :size => 12)
      default_leading 0
      self.text_direction = :ltr

      # Graphics settings
      self.line_width = 1
      self.cap_style  = :butt
      self.join_style = :miter
      undash
      fill_color   BLACK
      stroke_color BLACK
    end

  end
end
