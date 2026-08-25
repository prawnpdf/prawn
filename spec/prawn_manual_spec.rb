# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '7ef89fc18fcf59bf036e87f9db3570dd70a5b3d6433b8f919bd196d3b90822caf81a01d2055584b544fe2ef092175f0864198bb52ac4e29ab3aff51177ef7abf'
  when 'jruby'
    '26a22157859ce98cb164e5ac2b4ef45b6dc198f62539d84f3cc7fe28bf2f49809d78292800a986e1fb53952872b8f96a264249bef4c8681bdbed1fe6c8bccfe3'
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
