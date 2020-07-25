# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '85d2ded146d1e6659e9db389a071896d6e57d7cc4210c6b7fc75fc4afe2b5697'\
    '8a86baca785acd717964619dc234327ef59f5ba6d750dfd626279af0166f6c5e'
  when 'jruby'
    '85d2ded146d1e6659e9db389a071896d6e57d7cc4210c6b7fc75fc4afe2b5697'\
    '8a86baca785acd717964619dc234327ef59f5ba6d750dfd626279af0166f6c5e'
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
