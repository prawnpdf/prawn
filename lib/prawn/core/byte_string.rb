# encoding: utf-8
module Prawn
  module Core
    # This is used to differentiate strings that must be encoded as
    # a byte string, such as binary data from encrypted strings.
    class ByteString < String #:nodoc:
    end
  end
end
