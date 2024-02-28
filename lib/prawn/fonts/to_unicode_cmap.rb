# frozen_string_literal: true

module Prawn
  module Fonts
    # This class generates ToUnicode CMap for embedde TrueType/OpenType fonts.
    # It's a separate format and is somewhat complicated so it has its own
    # place.
    #
    # @private
    class ToUnicodeCMap
      # mapping is expected to be a hash with keys being character codes (in
      # broad sense, as used in the showing operation strings) and values being
      # Unicode code points.
      def initialize(mapping, code_space_size = nil)
        @mapping = mapping
        @code_space_size = code_space_size
      end

      # Generate CMap.
      #
      # @return [String]
      def generate
        chunks = []

        # Header
        chunks << <<~HEADER.chomp
          /CIDInit /ProcSet findresource begin
          12 dict begin
          begincmap
          /CIDSystemInfo 3 dict dup begin
            /Registry (Adobe) def
            /Ordering (UCS) def
            /Supplement 0 def
          end def
          /CMapName /Adobe-Identity-UCS def
          /CMapType 2 def
        HEADER

        max_glyph_index = mapping.keys.max
        # Range
        code_space_size = (max_glyph_index.bit_length / 8.0).ceil

        used_code_space_size = @code_space_size || code_space_size

        # In CMap codespaces are not sequentional, they're ranges in
        # a multi-dimentional space. Each byte is considered separately. So we
        # have to maximally extend the lower bytes in order to allow for
        # continuos mapping.
        # We only keep the highest byte because usually it's lower than
        # maximally allowed and we don't want to cover that unused space.
        code_space_max = max_glyph_index | ('ff' * (code_space_size - 1)).to_i(16)

        chunks << '1 begincodespacerange'
        chunks << format("<%0#{used_code_space_size * 2}X><%0#{used_code_space_size * 2}X>", 0, code_space_max)
        chunks << 'endcodespacerange'

        # Mapping
        all_spans = mapping_spans(mapping.reject { |gid, cid| gid.zero? || (0xd800..0xdfff).cover?(cid) })

        short_spans, long_spans = all_spans.partition { |span| span[0] == :short }

        long_spans
          .each_slice(100) do |spans|
            chunks << "#{spans.length} beginbfrange"

            spans.each do |type, span|
              # rubocop: disable Lint/FormatParameterMismatch # false positive
              case type
              when :fully_sorted
                chunks << format(
                  "<%0#{code_space_size * 2}X><%0#{code_space_size * 2}X><%s>",
                  span.first[0],
                  span.last[0],
                  span.first[1].chr(::Encoding::UTF_16BE).unpack1('H*'),
                )
              when :index_sorted
                chunks << format(
                  "<%0#{code_space_size * 2}X><%0#{code_space_size * 2}X>[%s]",
                  span.first[0],
                  span.last[0],
                  span.map { |_, cid| "<#{cid.chr(::Encoding::UTF_16BE).unpack1('H*')}>" }.join(''),
                )
              end
              # rubocop: enable Lint/FormatParameterMismatch
            end

            chunks << 'endbfrange'
          end

        short_spans
          .map { |_type, slice| slice.flatten(1) }
          .each_slice(100) do |mapping|
            chunks << "#{mapping.length} beginbfchar"
            chunks.concat(
              mapping.map { |(gid, cid)|
                # rubocop: disable Lint/FormatParameterMismatch # false positive
                format(
                  "<%0#{code_space_size * 2}X><%s>",
                  gid,
                  cid.chr(::Encoding::UTF_16BE).unpack1('H*'),
                )
                # rubocop: enable Lint/FormatParameterMismatch
              },
            )
            chunks << 'endbfchar'
          end

        # Footer
        chunks << <<~FOOTER.chomp
          endcmap
          CMapName currentdict /CMap defineresource pop
          end
          end
        FOOTER

        chunks.join("\n")
      end

      private

      attr_reader :mapping

      attr_reader :cmap
      attr_reader :code_space_size
      attr_reader :code_space_max

      def mapping_spans(mapping)
        mapping
          .sort
          .slice_when { |a, b| (b[0] - a[0]) != 1 } # Slice at key discontinuity
          .flat_map { |slice|
            if slice.length == 1
              [[:short, slice]]
            else
              continuous_slices, discontinuous_slices =
                slice
                  .slice_when { |a, b| b[1] - a[1] != 1 } # Slice at value discontinuity
                  .partition { |subslice| subslice.length > 1 }

              discontinuous_slices
                .flatten(1) # Join together
                .slice_when { |a, b| (b[0] - a[0]) != 1 } # Slice at key discontinuity, again
                .map { |span| span.length > 1 ? [:index_sorted, span] : [:short, slice] } +
                continuous_slices.map { |span| [:fully_sorted, span] }
            end
          } # rubocop: disable Style/MultilineBlockChain
          .sort_by { |span| span[1][0][0] } # Sort span start key
      end
    end
  end
end
