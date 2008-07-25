# TTF/Ruby, a library to read and write TrueType fonts in Ruby.
# Copyright (C) 2006  Mathieu Blondel
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

module Font
module TTF
module Encodings

module Platform
    UNICODE = 0
    MACINTOSH = 1
    ISO = 2
    MICROSOFT = 3

    ID2NAME = {
        UNICODE => "Unicode",
        MACINTOSH => "Macintosh",
        ISO => "ISO",
        MICROSOFT => "Microsoft"
    }
end

module UnicodeEncoding
# When Platform == 0
    DEFAULT_SEMANTICS = 0
    VERSION_1_1_SEMANTICS = 1
    ISO_10646_1993_SEMANTICS = 2
    UNICODE = 3
end

module MicrosoftEncoding
# When Platform == 3
    SYMBOL = 0
    UNICODE = 1
    SHIFTJIS = 2
    BIG5 = 3
    PRC = 4
    WASUNG = 5
    JOHAB = 6

    ID2NAME = {
        SYMBOL => "Symbol",
        UNICODE => "Unicode",
        SHIFTJIS => "ShiftJIS",
        BIG5 => "Big5",
        PRC => "PRC",
        WASUNG => "Wasung",
        JOHAB => "Johab"
    }
end

module MacintoshEncoding
# When Platform == 1
    ROMAN = 0
    JAPANESE = 1
    TRADITIONAL_CHINESE = 2
    KOREAN = 3
    ARABIC = 4
    HEBREW = 5
    GREEK = 6
    RUSSIAN = 7
    RSYMBOL = 8
    DEVANAGARI = 9
    GURMUKHI = 10
    GUJARATI = 11
    ORIYA = 12
    BENGALI = 13
    TAMIL = 14
    TELUGU = 15
    KANNADA = 16
    MALAYALAM = 17
    SINHALESE = 18
    BURMESE = 19
    KHMER = 20
    THAI = 21
    LAOTIAN = 22
    GEORGIAN = 23
    ARMENIAN = 24
    SIMPLIFIED_CHINESE = 25 
    TIBETAN = 26
    MONGOLIAN = 27
    GEEZ = 28
    SLAVIC = 29
    VIETNAMESE = 30
    SINDHI = 31
    UNINTERPRETED = 32

    ID2NAME = {
        ROMAN => "Roman",
        JAPANESE => "Japanese",
        TRADITIONAL_CHINESE => "Traditional Chinese",
        KOREAN => "Korean",
        ARABIC => "Arabic",
        HEBREW => "Hebrew",
        GREEK => "Greek",
        RUSSIAN => "Russian",
        RSYMBOL => "RSymbol",
        DEVANAGARI => "Devanagari",
        GURMUKHI => "Gurmukhi",
        GUJARATI => "Gujarati",
        ORIYA => "Orya",
        BENGALI => "Bengali",
        TAMIL => "Tamil",
        TELUGU => "Telugu",
        KANNADA => "Kannada",
        MALAYALAM => "Malayalam",
        SINHALESE => "Sinhalese",
        BURMESE => "Burmese",
        KHMER => "Khmer",
        THAI => "Thai",
        LAOTIAN => "Laotian",
        GEORGIAN => "Georgian",
        ARMENIAN => "Armenian",
        SIMPLIFIED_CHINESE => "Simplified Chinese",
        TIBETAN => "Tibetan",
        MONGOLIAN => "Mongolian",
        GEEZ => "Geez",
        SLAVIC => "Slavic",
        VIETNAMESE => "Vietnamese",
        SINDHI => "Sindhi",
        UNINTERPRETED => "Uninterpreted"
    }
end

end
end
end