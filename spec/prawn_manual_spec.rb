# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'ec48e17ba26f7d02cd3e7ed629170a5f6badb59e28ccc817d6e570a7d0b1a1e6c111c0daf54f28dfe67bebdca9381928c595c583b86fff7ec7b1eca28541d186'
  when 'jruby'
    '477f6eae16917f30f7fe4f6d7f18cd3752904b8871308f4a8d961d9098276bc4fc1835a07d8ddca0a2dbf110f0b60a9a45195ed0a021d3039cc243d5c67a6bc3'
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
