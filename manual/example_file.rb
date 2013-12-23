# encoding: utf-8

module Prawn
  
  # The Prawn::ExampleFile class is a utility class to ease the manipulation
  # and extraction of source code and comments from the actual example files
  #
  class ExampleFile
    attr_reader :package, :filename
    
    # Stores the file data, filename and parent, which will be either an
    # ExampleSection or an ExamplePackage.
    #
    # Available boolean options are:
    # 
    # <tt>:eval_source</tt>:: Evals the example source code (default: true)
    # <tt>:full_source</tt>:: Extract the full source code when true. Extract
    # only the code between the generate block when false (default: false)
    #
    def initialize(parent, filename, options={})
      @parent   = parent.is_a?(String) ? ExamplePackage.new(parent) : parent
      
      @filename = filename
      @data     = read_file(@parent.folder_name, filename)
      
      @options  = {:eval_source => true, :full_source => false}.merge(options)
    end
    
    # Return the example source code excluding the initial comments and
    # require calls
    #
    def full_source
      @data.gsub(/# encoding.*?\n.*require.*?\n\n/m, "\n").strip
    end
    
    # Return the example source contained inside the first generate block or
    # the full source if no generate block is found
    #
    def generate_block_source
      block = @data.slice(/\w+\.generate.*? do\n(.*)end/m, 1)
        
      return full_source unless block
      
      block.gsub(/^( ){2}/, "")
    end
    
    # Return either the full_source or the generate_block_source according
    # to the options
    #
    def source
      @options[:full_source] ? full_source : generate_block_source
    end
    
    # Return true if the example source should be evaluated inline within
    # the manual according to the options
    #
    def eval?
      @options[:eval_source]
    end
    
    # Retrieve the comments between the encoding declaration and the require
    # call for example_helper.rb
    #
    # Then removes the '#' signs, reflows the line breaks and return the result
    #
    def introduction_text
      intro = @data.slice(/# encoding.*?\n(.*)require File\.expand_path/m, 1)
      intro.gsub!(/\n# (?=\S)/m, ' ')
      intro.gsub!(/^#/, '')
      intro.gsub!("\n", "\n\n")
      intro.rstrip!
      intro
    end
    
    # Returns a human friendly version of the example file name
    #
    def name
      @name ||= @filename[/(.*)\.rb/, 1].gsub("_", " ").capitalize
    end
    
    # Returns this example's parent original folder name
    #
    def parent_folder_name
      @parent.folder_name
    end
    
    # Returns the human friendly version of this example parent name
    #
    def parent_name
      @parent.name
    end
    
    # Renders this example to a pdf
    #
    def render(pdf)
      pdf.render_example(self)
    end
    
  private
  
    # Read the data from a file in a given package
    #
    def read_file(folder_name, filename)
      data = File.read(File.expand_path(File.join(
        File.dirname(__FILE__), folder_name, filename)))

      data.encode(::Encoding::UTF_8)
    end
    
  end
end
