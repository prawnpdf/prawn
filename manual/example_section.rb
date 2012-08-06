# encoding: utf-8

module Prawn
  
  # The Prawn::ExampleSection class is a utility class to handle sections
  # of related examples within an ExamplePackage
  #
  class ExampleSection
    attr_reader :name
    
    def initialize(package, name)
      @package  = package
      @name     = name
      @examples = []
    end
    
    # Stores a new ExampleFile in the examples list
    #
    def example(filename, options={})
      @examples << ExampleFile.new(self, "#{filename}.rb", options)
    end

    # Returns this example's package original folder name
    #
    def folder_name
      @package.folder_name
    end
    
    # Returns the human friendly version of this section's package name
    #
    def package_name
      @package.name
    end
    
    # Renders the section to a pdf and iterates the examples list delegating the
    # examples to be rendered as well
    #
    def render(pdf)
      pdf.render_section(self)
      
      @examples.each do |example|
        example.render(pdf)
      end
    end
  end
end
