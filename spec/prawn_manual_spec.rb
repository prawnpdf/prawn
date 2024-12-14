# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '46d84d81a99028d9832c1848b6dabea1d0f84af0f25d4b5d473c0a304c3de612aeb54b76b76b870e26b6d547fd6e77b85d82d81a568139ff456959be5e18b057'
  when 'jruby'
    'd227479b25382ee61e0cb6345ada735b9ea8105b862c630e08da3c35e2ec702c171d9dd2ab30f71b16ab3ae5144a9cbe0f0591122710562c6624bc01e67a63b9'
  end

RSpec.describe Prawn do
  describe 'manual' do
    # JRuby's zlib is a bit quirky. It sometimes produces different output to
    # libzlib (used by MRI). It's still a proper deflate stream and can be
    # decompressed just fine, but for whatever reason, compression produces
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
