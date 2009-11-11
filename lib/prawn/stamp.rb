# encoding: utf-8
#
# stamp.rb : Implements a repeatable stamp
#
# Copyright October 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Stamp

    def stamp(user_defined_name)
      raise Prawn::Errors::InvalidName if user_defined_name.empty?
      unless stamp_dictionary_registry[user_defined_name]
        raise Prawn::Errors::UndefinedObjectName
      end
      
      dict = stamp_dictionary_registry[user_defined_name]

      stamp_dictionary_name = dict[:stamp_dictionary_name]
      stamp_dictionary = dict[:stamp_dictionary]

      add_content "/#{stamp_dictionary_name} Do"
      
      page_xobjects.merge!(stamp_dictionary_name => stamp_dictionary)
    end
    
    def stamp_at(user_defined_name, point)
      # Save the graphics state
      add_content "q"

      # Translate the user space
      x,y = point
      translate_position = "1 0 0 1 %.3f %.3f cm" % [x, y]
      add_content translate_position
      
      # Draw the stamp in the now translated user space
      stamp(user_defined_name)
      
      # Restore the graphics state to remove the translation
      add_content "Q"
    end
    
    def create_stamp(user_defined_name="", &block)
      raise Prawn::Errors::InvalidName if user_defined_name.empty?

      if stamp_dictionary_registry[user_defined_name]
        raise Prawn::Errors::NameTaken
      end

      # BBox origin is the lower left margin of the page, so we need
      # it to be the full dimension of the page, or else things that
      # should appear near the top or right margin are invisible
      stamp_dictionary = ref!(:Type    => :XObject,
                              :Subtype => :Form,
                              :BBox => [0, 0, page_dimensions[2], page_dimensions[3]])

      stamp_dictionary_name = "Stamp#{next_stamp_dictionary_id}"

      stamp_dictionary_registry[user_defined_name] = 
        { :stamp_dictionary_name => stamp_dictionary_name, 
          :stamp_dictionary      => stamp_dictionary}

      
      @active_stamp_stream = ""
      @active_stamp_dictionary = stamp_dictionary

      yield if block_given?

      stamp_dictionary.data[:Length] = @active_stamp_stream.length + 1
      stamp_dictionary << @active_stamp_stream

      @active_stamp_stream = nil
      @active_stamp_dictionary = nil
    end
    
    private

    def stamp_dictionary_registry
      @stamp_dictionary_registry ||= {}
    end

    def next_stamp_dictionary_id
      stamp_dictionary_registry.length + 1
    end

  end
end
