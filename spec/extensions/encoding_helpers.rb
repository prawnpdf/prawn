# frozen_string_literal: true

# String encoding helpers.
module EncodingHelpers
  # Make sure the string is Windows-1252 -encoded.
  def win1252_string(str)
    str.dup.force_encoding(Encoding::Windows_1252)
  end

  # Make sure the string is binary-encoded
  def bin_string(str)
    str.dup.force_encoding(Encoding::ASCII_8BIT)
  end
end
