# frozen_string_literal: true

# background.rb: Provides a background system for Prawn
#
# Contributed by Michał Krajewski in March 2023
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    attr_reader :background
  end

  class Background
    attr_reader :file_landscape, :file_portrait, :scale, :page_size
    attr_accessor :at, :layout

    # Creates a new PDF background.  The following options are available (with
    # the default values marked in [])
    #
    # <tt>:background</tt>:: An image path to be used as background on all pages
    #                        [nil]
    # <tt>:background_landscape</tt>:: A landscape image path to be used as
    #                        background on all pages [nil]
    # <tt>:background_portrait</tt>:: A portrait image path to be used as
    #                        background on all pages [nil]
    # <tt>:background_dimensions</tt>:: Backgound image dimension strategy
    #                        [:scale] [nil]
    # <tt>:background_scale</tt>:: Backgound image scale [1] [nil]
    # <tt>:background_enabled</tt>:: Backgound enable [true] [nil]
    #
    # Usage:
    #
    #   # New background
    #   pdf = Prawn::Background.new(background: "file.jpg")
    #
    def initialize(options={})
      # Defalt option
      if options[:background]
        if options[:page_layout] == :landscape
          options[:background_landscape] = options[:background]
        else
          options[:background_portrait] = options[:background]
        end
      end

      @file_landscape = options[:background_landscape]
      @file_portrait  = options[:background_portrait]
      @scale          = options[:background_scale] || 1
      @enabled        = ( options[:background_enabled].nil? ? true : options[:background_enabled])
      @dimensions     = options[:background_dimensions] || :scale
      @page_size      = options[:page_size]
      @layout         = options[:page_layout] || :portrait

    end

    # @method disable
    #
    # Disable rendering background
    #
    def disable
      @enabled = false
    end

    # @method enable
    #
    # Enable rendering background
    #
    def enable
      @enabled = true
    end

    # @method file
    #
    # Return file url to generate a background image
    #
    def file
      portrait? ? file_portrait : file_landscape
    end

    # @method options
    #
    # Return options to generate a background image
    #
    def options
      hash = {}
      hash[:scale]  = scale   if dimensions_scale?
      hash[:fit]    = fit     if dimensions_fit?
      hash[:at]     = at
      hash
    end

    # @method render?
    #
    # Check if background is to render
    #
    def render?
      @enabled && !file.nil?
    end

    # @method update(params)
    #
    # Update background state. The following options are available (with
    # the default values marked in [])
    #
    # <tt>:at</tt>:: Set current at position
    # <tt>:layout</tt>:: Set current layout. Either <tt>:portrait</tt> or <tt>:landscape</tt>
    def update(params)
      params.each do |key, value|
        send("#{key}=", value)
      end
    end

    private

    def dimensions_fit?
      @dimensions.to_sym == :fit
    end

    def dimensions_scale?
      @dimensions.to_sym == :scale
    end
    
    def fit
      # TODO: put size format here
      size = PDF::Core::PageGeometry::SIZES[page_size]
      portrait? ? size : size.reverse
    end

    def landscape?
      layout == :landscape
    end

    def portrait?
      layout == :portrait
    end
  end
end