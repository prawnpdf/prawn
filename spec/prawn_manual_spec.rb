# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '1122056c91163df082ffd5d4950ce1c66ca30f49642c065fe44c57d20370750a'\
    '26fc3992a49fa3436dece1e1994b49fbdff4424837e34a7e412b18381abb0353'
  when 'jruby'
    '1122056c91163df082ffd5d4950ce1c66ca30f49642c065fe44c57d20370750a'\
    '26fc3992a49fa3436dece1e1994b49fbdff4424837e34a7e412b18381abb0353'
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
