# encoding: utf-8

module Prawn
  
  # The Prawn::ExampleFile class is a utility class to ease the manipulation
  # and extraction of source code and comments from the actual example files
  #
  class ExampleFile
    
    # Read the data from a file in a given package
    #
    def initialize(package, file)
      @data = File.read(File.expand_path(File.join(
        File.dirname(__FILE__), package, file)))
      
      # XXX If we ever have manual files with source encodings other than
      # UTF-8, we will need to fix this to work on Ruby 1.9.
      if @data.respond_to?(:encode!)
        @data.encode!("UTF-8")
      end
    end
    
    # Return the example source code excluding the initial comments and
    # require calls
    #
    def full_source
      @data.gsub(/# encoding.*?\n.*require.*?\n\n/m, "\n")
    end
    
    # Return the example source contained inside the first generate block or
    # the full source if no generate block is found
    #
    def generate_block_source
      @data.slice(/\w+\.generate.*? do(.*)end/m, 1) or full_source
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
