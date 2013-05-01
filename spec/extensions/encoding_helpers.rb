module EncodingHelpers
  def win1252_string(str)
    ruby_19 { str.force_encoding("Windows-1252") }
    str
  end
end
