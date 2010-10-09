# Allow speccing things when an expectation matcher runs. Similar to #with, but
# always succeeds.
#
#   @pdf.expects(:stroke_line).checking do |from, to|
#     @pdf.map_to_absolute(from).should == [0, 0]
#   end
#
# Note that the outer expectation does *not* fail only because the inner one
# does; in the above example, the outer expectation would only fail if
# stroke_line were not called.

class ParameterChecker < Mocha::ParametersMatcher
  def initialize(&matching_block)
    @matching_block = matching_block
    @run_matching_block = false
  end

  def match?(actual_parameters = [])
    @matching_block.call(*actual_parameters) unless @run_matching_block
    @run_matching_block = true

    true # always succeed
  end
end

class Mocha::Expectation
  def checking(&block)
    @parameters_matcher = ParameterChecker.new(&block)
    self
  end
end

