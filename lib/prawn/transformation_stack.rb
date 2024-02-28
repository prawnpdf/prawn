# frozen_string_literal: true

require 'matrix'

module Prawn
  # Stores the transformations that have been applied to the document.
  # @private
  module TransformationStack
    # rubocop: disable Metrics/ParameterLists, Naming/MethodParameterName

    # Add transformation to the stack.
    #
    # @param a [Number]
    # @param b [Number]
    # @param c [Number]
    # @param d [Number]
    # @param e [Number]
    # @param f [Number]
    # @return [void]
    def add_to_transformation_stack(a, b, c, d, e, f)
      @transformation_stack ||= [[]]
      @transformation_stack.last.push([a, b, c, d, e, f].map { |i| Float(i) })
    end

    # Save transformation stack.
    #
    # @return [void]
    def save_transformation_stack
      @transformation_stack ||= [[]]
      @transformation_stack.push(@transformation_stack.last.dup)
    end

    # Restore previous transformation.
    #
    # Effectively pops the last transformation off of the transformation stack.
    #
    # @return [void]
    def restore_transformation_stack
      @transformation_stack&.pop
    end

    # Get current transformation matrix. It's a result of multiplication of the
    # whole transformation stack with additional translation.
    #
    # @param x [Number]
    # @param y [Number]
    # @return [Array(Number, Number, Number, Number, Number, Number)]
    def current_transformation_matrix_with_translation(x = 0, y = 0)
      transformations = (@transformation_stack || [[]]).last

      matrix = Matrix.identity(3)

      transformations.each do |a, b, c, d, e, f|
        matrix *= Matrix[[a, c, e], [b, d, f], [0, 0, 1]]
      end

      matrix *= Matrix[[1, 0, x], [0, 1, y], [0, 0, 1]]

      matrix.to_a[0..1].transpose.flatten
    end
    # rubocop: enable Metrics/ParameterLists, Naming/MethodParameterName
  end
end
