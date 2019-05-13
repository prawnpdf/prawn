# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '0b6348280c2bd694d32e687bbe8e04d1659f09624ab9787186a933f4e1274382'\
    'a7d8eda06dd168da955a39d34ebafbf5a1c20a62f2a2a34281e4732beaba47a0'
  when 'jruby'
    '1df4c83bc2dadb6368b755dfbed87f2730243023c8e7ceb8dc283eb9a485bf89'\
    '644baf93e6e2f016f7c990a47dd001080904f0c60066025ef2204769b906d173'
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

      require File.expand_path(File.join(__dir__, %w[.. manual contents]))
      s = prawn_manual_document.render

      hash = Digest::SHA512.hexdigest(s)

      expect(hash).to eq MANUAL_HASH
    end
  end
end
