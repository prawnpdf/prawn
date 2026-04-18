# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'f7701682edafd053b6c1463f66cc0f7495505bb1107e4fafd142fed4d1c8009c8c83777c8c7b5884bfd63fc99e66095c068bdf0889e4703bb748664503f539f7'
  when 'jruby'
    'e188afa9b5b8b28f85e6c0fd82621156fc32a6adda1373ecc0c535c1949de5e9c443079abc50d26e3a035ec7c218652a65973656efdbc46f4bd32df2f6d93748'
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
