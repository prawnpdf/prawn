module EncodingHelpers
  def win1252_string(str)
    ruby_19 { str.force_encoding("Windows-1252") }
    str
  end

  def bin_string(str)
    ruby_19 { str.force_encoding("ASCII-8BIT") } || ruby_18 { str }
  end
end
