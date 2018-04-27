# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

# rubocop: disable Metrics/LineLength
MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'acd3a58107c2ff505db57e985d3d47406f3285972d8878d274bdbe2247a279b98439ce1f42f18fb08938df70e4bdf5b226cdbbd5d2e38874a8fe1b346f3237b2'
  when 'jruby'
    '2c5d08b2d5f095549802ad49d888111361843127f305ca8d55aa1638638073eaea52258bcb04dd2416ab250d28bea648496d148d011351f62cf00b5443713cf4'
  end
# rubocop: enable Metrics/LineLength

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
