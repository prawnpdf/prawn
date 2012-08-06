# encoding: utf-8

module Prawn
  
  # The Prawn::ExamplePackage class is a utility class to handle the packaging
  # of individual examples within a hierarchy when building the manual
  #
  class ExamplePackage
    attr_reader :intro_block, :folder_name
    
    def initialize(folder_name)
      @folder_name = folder_name
      @hierarchy = []
    end
    
    # Stores a new ExampleSection in the hierarchy and yields it to a block
    #
    def section(name)
      s = ExampleSection.new(self, name)
      yield s
      @hierarchy << s
    end
    
    # Stores a new ExampleFile in the hierarchy
    #
    def example(filename, options={})
      @hierarchy << ExampleFile.new(self, "#{filename}.rb", options)
    end
    
    # Stores a block with code to be evaluated when rendering the package cover
    #
    def intro(&block)
      @intro_block = block
    end
    
    # Returns a human friendly version of the package name
    #
    def name
      @name ||= @folder_name.gsub("_", " ").capitalize
    end
    
    # Renders a cover page for the package to a pdf and iterates the examples
    # hierarchy delegating the examples and sections to be rendered as well
    #
    def render(pdf)
      pdf.render_package_cover(self)
      
      @hierarchy.each do |node|
        node.render(pdf)
      end
    end
  end
end
