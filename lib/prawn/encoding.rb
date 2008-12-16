# encoding: utf-8
#
# Copyright September 2008, Gregory Brown, James Healy  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
module Prawn
  module Encoding
    # Map between unicode and WinAnsiEnoding
    #
    class WinAnsi #:nodoc:
      CHARACTERS = %w[
        .notdef       .notdef        .notdef        .notdef
        .notdef       .notdef        .notdef        .notdef
        .notdef       .notdef        .notdef        .notdef
        .notdef       .notdef        .notdef        .notdef
        .notdef       .notdef        .notdef        .notdef
        .notdef       .notdef        .notdef        .notdef
        .notdef       .notdef        .notdef        .notdef
        .notdef       .notdef        .notdef        .notdef
        
        space         exclam         quotedbl       numbersign
        dollar        percent        ampersand      quotesingle
        parenleft     parenright     asterisk       plus
        comma         hyphen         period         slash
        zero          one            two            three
        four          five           six            seven
        eight         nine           colon          semicolon
        less          equal          greater        question

        at            A              B              C
        D             E              F              G
        H             I              J              K
        L             M              N              O
        P             Q              R              S
        T             U              V              W
        X             Y              Z              bracketleft
        backslash     bracketright   asciicircum    underscore

        grave         a              b              c
        d             e              f              g
        h             i              j              k
        l             m              n              o
        p             q              r              s
        t             u              v              w
        x             y              z              braceleft
        bar           braceright     asciitilde     .notdef

        Euro          .notdef        quotesinglbase florin
        quotedblbase  ellipsis       dagger         daggerdbl
        circumflex    perthousand    Scaron         guilsinglleft
        OE            .notdef        Zcaron         .notdef
        .notdef       quoteleft      quoteright     quotedblleft
        quotedblright bullet         endash         emdash
        tilde         trademark      scaron         guilsinglright
        oe            .notdef        zcaron         ydieresis
       
        space         exclamdown     cent           sterling
        currency      yen            brokenbar      section
        dieresis      copyright      ordfeminine    guillemotleft
        logicalnot    hyphen         registered     macron
        degree        plusminus      twosuperior    threesuperior
        acute         mu             paragraph      periodcentered
        cedilla       onesuperior    ordmasculine   guillemotright
        onequarter    onehalf        threequarters  questiondown

        Agrave        Aacute         Acircumflex    Atilde
        Adieresis     Aring          AE             Ccedilla
        Egrave        Eacute         Ecircumflex    Edieresis
        Igrave        Iacute         Icircumflex    Idieresis
        Eth           Ntilde         Ograve         Oacute
        Ocircumflex   Otilde         Odieresis      multiply
        Oslash        Ugrave         Uacute         Ucircumflex
        Udieresis     Yacute         Thorn          germandbls

        agrave        aacute         acircumflex    atilde
        adieresis     aring          ae             ccedilla
        egrave        eacute         ecircumflex    edieresis
        igrave        iacute         icircumflex    idieresis
        eth           ntilde         ograve         oacute
        ocircumflex   otilde         odieresis      divide
        oslash        ugrave         uacute         ucircumflex
        udieresis     yacute         thorn          ydieresis
      ]    
      
      def initialize
        @mapping_file = "#{Prawn::BASEDIR}/data/encodings/win_ansi.txt"
        load_mapping if self.class.mapping.empty?
      end

      # Converts a Unicode codepoint into a valid WinAnsi single byte character.
      #
      # If there is no WinAnsi equivlant for a character, a _ will be substituted.
      #
      def [](codepoint)
        # unicode codepoints < 255 map directly to the single byte value in WinAnsi
        return codepoint if codepoint <= 255

        # There are a handful of codepoints > 255 that have equivilants in WinAnsi.
        # Replace anything else with an underscore
        self.class.mapping[codepoint] || 95
      end
      
      def self.mapping
        @mapping ||= {}
      end

      private

      def load_mapping
        RUBY_VERSION >= "1.9" ? mode = "r:BINARY" : mode = "r"
        File.open(@mapping_file, mode) do |f|
          f.each do |l|
            m, single_byte, unicode = *l.match(/([0-9A-Za-z]+);([0-9A-F]{4})/)
            self.class.mapping["0x#{unicode}".hex] = "0x#{single_byte}".hex if single_byte
          end
        end
      end
    end
  end
end
