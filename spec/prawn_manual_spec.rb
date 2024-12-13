# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '06ce69758c64b0e5f14d09474d94ba580aaa4edca7014c6ab5bc9536b5bb0d0c163425aceff74a0ad3867859f8372e07b96e63822cc0e789549bb3a35d3cf185'
  when 'jruby'
    '31b7c93ddf81f0c734a036644f07541071af36cee1f2e9a6c99847bd98ae6a66a9755afb69f4351fac711382bfc04d1cb50bc00122d7c4d187428f1582680794'
  end

RSpec.describe Prawn do
  describe 'manual' do
    # JRuby's zlib is a bit quirky. It sometimes produces different output to
    # libzlib (used by MRI). It's still a proper deflate stream and can be
    # decompressed just fine but, for whatever reason, compression produces
    # different output.
    #
    # See: https://github.com/jruby/jruby/issues/4244
    it 'contains no unexpected changes' do
      ENV['CI'] ||= 'true'

      manual_path = File.expand_path('../manual/manual.rb', __dir__)
      manual = eval(File.read(manual_path), TOPLEVEL_BINDING, manual_path) # rubocop: disable Security/Eval
      s = manual.generate

      hash = Digest::SHA512.hexdigest(s)

      expect(hash).to eq MANUAL_HASH
    end
  end
end
