# frozen_string_literal: true

module Prawn
  # Custom error classes for Prawn.
  module Errors
    # Raised when a table is spanned in an impossible way.
    class InvalidTableSpan < StandardError
    end

    # This error is raised when a method requiring a current page is called
    # without being on a page.
    class NotOnPage < StandardError
    end

    # This error is raised when Prawn cannot find a specified font.
    class UnknownFont < StandardError
    end

    # Raised when Prawn is asked to draw something into a too-small box.
    class CannotFit < StandardError
    end

    # Raised if {#group} is called with a block that is too big to be rendered
    # in the current context.
    #
    # @private
    class CannotGroup < StandardError
    end

    # This error is raised when Prawn is being used on a M17N aware VM, and the
    # user attempts to add text that isn't compatible with UTF-8 to their
    # document.
    class IncompatibleStringEncoding < StandardError
    end

    # This error is raised when Prawn encounters an unknown key in functions
    # that accept an options hash.  This usually means there is a typo in your
    # code or that the option you are trying to use has a different name than
    # what you have specified.
    class UnknownOption < StandardError
    end

    # This error is raised when a user attempts to embed an image of an
    # unsupported type. This can either a completely unsupported format, or
    # a dialect of a supported format (i.e. some types of PNG).
    class UnsupportedImageType < StandardError
    end

    # This error is raised when a named element has already been created. For
    # example, in the stamp module, stamps must have unique names within
    # a document.
    class NameTaken < StandardError
    end

    # This error is raised when a name is not a valid format.
    class InvalidName < StandardError
    end

    # This error is raised when an object is attempted to be referenced by name,
    # but no such name is associated with an object.
    class UndefinedObjectName < StandardError
    end

    # This error is raised when a required option has not been set.
    class RequiredOption < StandardError
    end

    # This error is raised when a requested outline item with a given title does
    # not exist.
    class UnknownOutlineTitle < StandardError
    end

    # This error is raised when a block is required, but not provided.
    class BlockRequired < StandardError
    end

    # This error is raised when a graphics method is called with improper
    # arguments.
    class InvalidGraphicsPath < StandardError
    end

    # Raised when unrecognized content is provided for a table cell.
    class UnrecognizedTableContent < StandardError
    end

    # This error is raised when an incompatible join style is specified.
    class InvalidJoinStyle < StandardError
    end
  end
end
