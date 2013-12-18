module EncodingHelpers
  def win1252_string(str)
    str.force_encoding("Windows-1252")
  end

  def bin_string(str)
    str.force_encoding("ASCII-8BIT")
  end
end
