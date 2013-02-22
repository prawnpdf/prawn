# encoding: utf-8

# prawn/core/filters.rb : Implements stream filters
#
# Copyright February 2013, Alexander Mankuta.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'zlib'

module Prawn
  module Core
    module Filters
      module ASCIIHexDecode
        def self.encode(stream)
          result = ''

          stream.each_byte do |byte|
            result << byte.to_s(16)
          end

          result + '>'
        end

        def self.decode(stream)
          result = ''

          data = stream.gsub(/[\x00\x09\x0a\x0c\x0d\x20]/, '') # Whitespaces are ignored
          if data =~ />/
            data = data.split('>')[0] # Decode up untill EOD marker
            if data.length.odd?
              data << '0'
            end
          end

          if data =~ /[^0-9a-fA-F]/
            raise "ASCIIHexDecode filter encountered unexpected data in stream"
          end

          data.scan(/../).each do |hex|
            result << hex.to_i(16)
          end

          result
        end
      end

      module ASCII85Decode
        require 'strscan'

        def self.encode(stream)
          return '' if stream.empty?

          padding = 4 - stream.bytesize % 4

          # Extract big-endian integers
          groups = (stream + ("\0" * padding)).unpack('N*')

          # Encode
          groups.map! do |group|
            if group == 0
              'z'
            else
              tmp = ""
              5.times do
                tmp << ((group % 85) + 33).chr
                group /= 85
              end
              tmp.reverse
            end
          end

          # We can't use the z-abbreviation if we're going to cut off padding
          if (padding > 0) && (groups.last == 'z')
            groups[-1] = '!!!!!'
          end

          # Cut off the padding
          groups[-1] = groups[-1][0..(4 - padding)]

          groups.join('') + '~>'
        end

        def self.decode(stream)
          data = stream.gsub(/[\x00\x09\x0a\x0c\x0d\x20]/, '') # Whitespaces are ignored
          if data =~ /~>/
            data = data.split('~>')[0] # Decode up until EOD marker
          end

          s = StringScanner.new(data)

          padding = 0
          result = ''

          until s.eos?
            group = s.scan(/z|[^z]{,5}/)
            if group == 'z'
              group = '!!!!!'
            end

            if group.length < 5
              if s.eos?
                padding = 5 - group.length
                group << 'u' * padding
              else
                raise "Malformed data at #{s.pos}"
              end
            end

            word = 0

            group.unpack('C*').each_with_index do |byte, i|
              word += (byte - 33) * 85 ** (4 - i)
            end
            result << [word].pack('N')

            if padding > 0
              result = result[0...-padding]
            end
          end

          result
        end
      end

      module FlateDecode
        def self.encode(stream, params = nil)
          Zlib::Deflate.deflate(stream)
        end

        def self.decode(stream, params = nil)
          Zlib::Inflate.inflate(stream)
        end
      end

      # Pass through stub
      module DCTDecode
        def self.encode(stream, params = nil)
          stream
        end

        def self.decode(stream, params = nil)
          stream
        end
      end
    end
  end
end
