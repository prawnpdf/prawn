# frozen_string_literal: true

require 'spec_helper'
require 'digest/sha2'

MANUAL_HASH =
  case RUBY_ENGINE
  when 'ruby'
    'e9f599d2ec19846d51faefbd9f2cd9f8d0a729b56103418e11cf08d129f986b899e18e55b5706575e3d3a3b0e4dbaef021ac81f98a5658ee33ebca4e35a26455'
  when 'jruby'
    '598c7e8c474dcc4e61ae5849cfb4a145129095ca37ca55641473e0898291f0296c7c07c201b80997c2f3efebfd67b428bf71376f95f1680f776db529ccbe87f9'
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
      manual = eval(File.read(manual_path), TOPLEVEL_BINDING, manual_path)
      s = manual.generate

      hash = Digest::SHA512.hexdigest(s)

      expect(hash).to eq MANUAL_HASH
    end
  end
end
