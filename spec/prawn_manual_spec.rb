# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '7ef89fc18fcf59bf036e87f9db3570dd70a5b3d6433b8f919bd196d3b90822caf81a01d2055584b544fe2ef092175f0864198bb52ac4e29ab3aff51177ef7abf'
  when 'jruby'
    '31b7c93ddf81f0c734a036644f07541071af36cee1f2e9a6c99847bd98ae6a66a9755afb69f4351fac711382bfc04d1cb50bc00122d7c4d187428f1582680794'
  end

RSpec.describe Prawn do
  describe 'manual' do
    # JRuby's zlib is a bit quirky. It sometimes produces different output to
    # libzlib (used by MRI). It's still a proper deflate stream and can be
    # decompressed just fine but for whatever reason compressin produses
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
