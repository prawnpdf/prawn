# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby', 'truffleruby'
    'bcba28d39698ac349a626e1bc3d6a354d20bd7da340190bc8843cec1be3caefb'\
    '88fc9591edba9cf21d7f2e08faf40a40d269b26b5c5ac6afb8c7fb61cba8c544'
  when 'jruby'
    'fc28a61d956326664aba40e2fa41bda2ffc112ce95c6b689be01f5e909038b09'\
    '6b93f6445cf4b324b2d13dc794edc88ee2116db556dd6ae5c7d350e963d1f45a'
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
