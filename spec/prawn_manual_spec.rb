# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    '3ed0d891749b7d22543920dec949c7db73393b5456b0fdaa938148bc9078dcf4'\
    '0188f5c495773bf9b2996cf62db18286b6f8cbaf18f2ec83d02eafa14c5b63e9'
  when 'jruby'
    '3ed0d891749b7d22543920dec949c7db73393b5456b0fdaa938148bc9078dcf4'\
    '0188f5c495773bf9b2996cf62db18286b6f8cbaf18f2ec83d02eafa14c5b63e9'
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
