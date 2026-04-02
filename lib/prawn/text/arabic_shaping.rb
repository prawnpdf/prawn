# frozen_string_literal: true

require 'set'

module Prawn
  module Text
    # Arabic text shaping for Prawn PDF.
    #
    # Arabic is a cursive script where each character has up to 4 forms
    # (isolated, initial, medial, final) depending on its position in a word.
    # Prawn uses ttfunk for font parsing but does not perform OpenType text
    # shaping (GSUB lookups for init/medi/fina/isol features). Without shaping,
    # Arabic characters render in their isolated form — disconnected and
    # unreadable.
    #
    # This module converts Arabic characters to their correct Unicode
    # Presentation Forms (U+FE70-U+FEFF, U+FB50-U+FDFF) based on joining
    # context, which produces correctly connected Arabic text without requiring
    # a full OpenType shaping engine.
    #
    # Supports:
    # - All standard Arabic letters (U+0621-U+064A)
    # - Extended Arabic characters (Farsi, Urdu, etc.)
    # - Lam-Alef mandatory ligatures
    # - Diacritical marks (tashkeel) preservation
    # - Tatweel (kashida) joining
    #
    # @example Basic usage
    #   shaped = Prawn::Text::ArabicShaping.shape("مرحبا بالعالم")
    #
    # @example Automatic shaping with direction: :rtl
    #   pdf.text "مرحبا", direction: :rtl  # shaping applied automatically
    #
    module ArabicShaping
      # Maps Arabic base characters to their presentation forms:
      # [isolated, final, initial, medial]
      ARABIC_FORMS = {
        0x0621 => [0xFE80, nil, nil, nil], # HAMZA
        0x0622 => [0xFE81, 0xFE82, nil, nil], # ALEF WITH MADDA ABOVE
        0x0623 => [0xFE83, 0xFE84, nil, nil], # ALEF WITH HAMZA ABOVE
        0x0624 => [0xFE85, 0xFE86, nil, nil], # WAW WITH HAMZA ABOVE
        0x0625 => [0xFE87, 0xFE88, nil, nil], # ALEF WITH HAMZA BELOW
        0x0626 => [0xFE89, 0xFE8A, 0xFE8B, 0xFE8C], # YEH WITH HAMZA ABOVE
        0x0627 => [0xFE8D, 0xFE8E, nil, nil], # ALEF
        0x0628 => [0xFE8F, 0xFE90, 0xFE91, 0xFE92], # BEH
        0x0629 => [0xFE93, 0xFE94, nil, nil], # TEH MARBUTA
        0x062A => [0xFE95, 0xFE96, 0xFE97, 0xFE98], # TEH
        0x062B => [0xFE99, 0xFE9A, 0xFE9B, 0xFE9C], # THEH
        0x062C => [0xFE9D, 0xFE9E, 0xFE9F, 0xFEA0], # JEEM
        0x062D => [0xFEA1, 0xFEA2, 0xFEA3, 0xFEA4], # HAH
        0x062E => [0xFEA5, 0xFEA6, 0xFEA7, 0xFEA8], # KHAH
        0x062F => [0xFEA9, 0xFEAA, nil, nil], # DAL
        0x0630 => [0xFEAB, 0xFEAC, nil, nil], # THAL
        0x0631 => [0xFEAD, 0xFEAE, nil, nil], # REH
        0x0632 => [0xFEAF, 0xFEB0, nil, nil], # ZAIN
        0x0633 => [0xFEB1, 0xFEB2, 0xFEB3, 0xFEB4], # SEEN
        0x0634 => [0xFEB5, 0xFEB6, 0xFEB7, 0xFEB8], # SHEEN
        0x0635 => [0xFEB9, 0xFEBA, 0xFEBB, 0xFEBC], # SAD
        0x0636 => [0xFEBD, 0xFEBE, 0xFEBF, 0xFEC0], # DAD
        0x0637 => [0xFEC1, 0xFEC2, 0xFEC3, 0xFEC4], # TAH
        0x0638 => [0xFEC5, 0xFEC6, 0xFEC7, 0xFEC8], # ZAH
        0x0639 => [0xFEC9, 0xFECA, 0xFECB, 0xFECC], # AIN
        0x063A => [0xFECD, 0xFECE, 0xFECF, 0xFED0], # GHAIN
        0x0640 => [0x0640, 0x0640, 0x0640, 0x0640], # TATWEEL
        0x0641 => [0xFED1, 0xFED2, 0xFED3, 0xFED4], # FEH
        0x0642 => [0xFED5, 0xFED6, 0xFED7, 0xFED8], # QAF
        0x0643 => [0xFED9, 0xFEDA, 0xFEDB, 0xFEDC], # KAF
        0x0644 => [0xFEDD, 0xFEDE, 0xFEDF, 0xFEE0], # LAM
        0x0645 => [0xFEE1, 0xFEE2, 0xFEE3, 0xFEE4], # MEEM
        0x0646 => [0xFEE5, 0xFEE6, 0xFEE7, 0xFEE8], # NOON
        0x0647 => [0xFEE9, 0xFEEA, 0xFEEB, 0xFEEC], # HEH
        0x0648 => [0xFEED, 0xFEEE, nil, nil], # WAW
        0x0649 => [0xFEEF, 0xFEF0, nil, nil], # ALEF MAKSURA
        0x064A => [0xFEF1, 0xFEF2, 0xFEF3, 0xFEF4], # YEH

        # Extended Arabic (Farsi, Urdu, etc.)
        0x0671 => [0xFB50, 0xFB51, nil, nil], # ALEF WASLA
        0x0679 => [0xFB66, 0xFB67, 0xFB68, 0xFB69], # TTEH
        0x067A => [0xFB5E, 0xFB5F, 0xFB60, 0xFB61], # TTEHEH
        0x067B => [0xFB52, 0xFB53, 0xFB54, 0xFB55], # BEEH
        0x067E => [0xFB56, 0xFB57, 0xFB58, 0xFB59], # PEH
        0x067F => [0xFB62, 0xFB63, 0xFB64, 0xFB65], # TEHEH
        0x0680 => [0xFB5A, 0xFB5B, 0xFB5C, 0xFB5D], # BEHEH
        0x0683 => [0xFB76, 0xFB77, 0xFB78, 0xFB79], # NYEH
        0x0684 => [0xFB72, 0xFB73, 0xFB74, 0xFB75], # DYEH
        0x0686 => [0xFB7A, 0xFB7B, 0xFB7C, 0xFB7D], # TCHEH
        0x0687 => [0xFB7E, 0xFB7F, 0xFB80, 0xFB81], # TCHEHEH
        0x0688 => [0xFB88, 0xFB89, nil, nil], # DDAL
        0x068C => [0xFB84, 0xFB85, nil, nil], # DAHAL
        0x068D => [0xFB82, 0xFB83, nil, nil], # DDAHAL
        0x068E => [0xFB86, 0xFB87, nil, nil], # DUL
        0x0691 => [0xFB8C, 0xFB8D, nil, nil], # RREH
        0x0698 => [0xFB8A, 0xFB8B, nil, nil], # JEH
        0x06A4 => [0xFB6A, 0xFB6B, 0xFB6C, 0xFB6D], # VEH
        0x06A6 => [0xFB6E, 0xFB6F, 0xFB70, 0xFB71], # PEHEH
        0x06A9 => [0xFB8E, 0xFB8F, 0xFB90, 0xFB91], # KEHEH
        0x06AD => [0xFBD3, 0xFBD4, 0xFBD5, 0xFBD6], # NG
        0x06AF => [0xFB92, 0xFB93, 0xFB94, 0xFB95], # GAF
        0x06B1 => [0xFB9A, 0xFB9B, 0xFB9C, 0xFB9D], # NGOEH
        0x06B3 => [0xFB96, 0xFB97, 0xFB98, 0xFB99], # GUEH
        0x06BA => [0xFB9E, 0xFB9F, nil, nil], # NOON GHUNNA
        0x06BB => [0xFBA0, 0xFBA1, 0xFBA2, 0xFBA3], # RNOON
        0x06BE => [0xFBAA, 0xFBAB, 0xFBAC, 0xFBAD], # HEH DOACHASHMEE
        0x06C0 => [0xFBA4, 0xFBA5, nil, nil], # HEH WITH YEH ABOVE
        0x06C1 => [0xFBA6, 0xFBA7, 0xFBA8, 0xFBA9], # HEH GOAL
        0x06C5 => [0xFBE0, 0xFBE1, nil, nil], # KIRGHIZ OE
        0x06C6 => [0xFBD9, 0xFBDA, nil, nil], # OE
        0x06C7 => [0xFBD7, 0xFBD8, nil, nil], # U
        0x06C8 => [0xFBDB, 0xFBDC, nil, nil], # YU
        0x06C9 => [0xFBE2, 0xFBE3, nil, nil], # KIRGHIZ YU
        0x06CB => [0xFBDE, 0xFBDF, nil, nil], # VE
        0x06CC => [0xFBFC, 0xFBFD, 0xFBFE, 0xFBFF], # FARSI YEH
        0x06D0 => [0xFBE4, 0xFBE5, 0xFBE6, 0xFBE7], # E
        0x06D2 => [0xFBAE, 0xFBAF, nil, nil], # YEH BARREE
        0x06D3 => [0xFBB0, 0xFBB1, nil, nil], # YEH BARREE WITH HAMZA ABOVE
      }.freeze

      # Lam-Alef mandatory ligatures
      LAM_ALEF_LIGATURES = {
        0x0622 => [0xFEF5, 0xFEF6], # LAM + ALEF WITH MADDA [isolated, final]
        0x0623 => [0xFEF7, 0xFEF8], # LAM + ALEF WITH HAMZA ABOVE
        0x0625 => [0xFEF9, 0xFEFA], # LAM + ALEF WITH HAMZA BELOW
        0x0627 => [0xFEFB, 0xFEFC], # LAM + ALEF
      }.freeze

      # Arabic diacritical marks (tashkeel) - transparent to joining
      ARABIC_MARKS = (0x064B..0x065F).to_a.push(
        0x0610, 0x0611, 0x0612, 0x0613, 0x0614, 0x0615,
        0x0616, 0x0617, 0x0618, 0x0619, 0x061A,
        0x06D6, 0x06D7, 0x06D8, 0x06D9, 0x06DA, 0x06DB,
        0x06DC, 0x06DF, 0x06E0, 0x06E1, 0x06E2, 0x06E3,
        0x06E4, 0x06E7, 0x06E8, 0x06EA, 0x06EB, 0x06EC, 0x06ED,
        0x0670,
      ).freeze

      ARABIC_MARKS_SET = ARABIC_MARKS.to_set.freeze

      class << self
        # Returns true if the text contains Arabic characters.
        #
        # @param text [String]
        # @return [Boolean]
        def contains_arabic?(text)
          text.match?(/[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]/)
        end

        # Shape Arabic text by converting characters to their positional
        # presentation forms based on joining context.
        #
        # @param text [String] UTF-8 text potentially containing Arabic
        # @return [String] text with Arabic characters replaced by presentation forms
        def shape(text)
          return text if text.nil? || text.empty?
          return text unless contains_arabic?(text)

          chars = text.codepoints
          result = []
          i = 0

          while i < chars.length
            cp = chars[i]

            if arabic_letter?(cp)
              run = []
              while i < chars.length && (arabic_letter?(chars[i]) || arabic_mark?(chars[i]) || chars[i] == 0x0640)
                run << chars[i]
                i += 1
              end
              result.concat(shape_run(run))
            else
              result << cp
              i += 1
            end
          end

          result.pack('U*')
        end

        private

        def arabic_letter?(codepoint)
          ARABIC_FORMS.key?(codepoint)
        end

        def arabic_mark?(codepoint)
          ARABIC_MARKS_SET.include?(codepoint)
        end

        def dual_joining?(codepoint)
          forms = ARABIC_FORMS[codepoint]
          forms && forms[2] && forms[3]
        end

        def right_joining?(codepoint)
          forms = ARABIC_FORMS[codepoint]
          forms && forms[1] && !forms[2]
        end

        def join_causing?(codepoint)
          [0x0640, 0x200D].include?(codepoint)
        end

        def can_join_right?(codepoint)
          dual_joining?(codepoint) || right_joining?(codepoint) || join_causing?(codepoint)
        end

        def can_join_left?(codepoint)
          dual_joining?(codepoint) || join_causing?(codepoint)
        end

        def shape_run(run)
          bases = []
          marks_map = {}
          base_index = -1

          run.each do |cp|
            if arabic_mark?(cp)
              marks_map[base_index] ||= []
              marks_map[base_index] << cp
            else
              base_index += 1
              bases << cp
            end
          end

          shaped_bases = apply_lam_alef_ligatures(bases)
          result = []

          shaped_bases.each_with_index do |entry, idx|
            if entry.is_a?(Array)
              result << entry[0]
            else
              forms = ARABIC_FORMS[entry]
              if forms
                prev_joins = idx.positive? && prev_can_join_left?(shaped_bases, idx)
                next_joins = idx < shaped_bases.length - 1 && next_can_join_right?(shaped_bases, idx)
                result << select_form(forms, prev_joins, next_joins)
              else
                result << entry
              end
            end

            orig_idx = find_original_index(bases, shaped_bases, idx)
            result.concat(marks_map[orig_idx]) if marks_map[orig_idx]
          end

          result
        end

        def apply_lam_alef_ligatures(bases)
          result = []
          i = 0
          while i < bases.length
            if bases[i] == 0x0644 && i + 1 < bases.length && LAM_ALEF_LIGATURES.key?(bases[i + 1])
              alef = bases[i + 1]
              ligature_forms = LAM_ALEF_LIGATURES[alef]
              prev_joins = i.positive? && can_join_left?(bases[i - 1])
              ligature_cp = prev_joins ? ligature_forms[1] : ligature_forms[0]
              result << [ligature_cp, prev_joins ? :final : :isolated]
              i += 2
            else
              result << bases[i]
              i += 1
            end
          end
          result
        end

        def prev_can_join_left?(shaped_bases, idx)
          entry = shaped_bases[idx - 1]
          return false if entry.is_a?(Array)

          can_join_left?(entry)
        end

        def next_can_join_right?(shaped_bases, idx)
          entry = shaped_bases[idx + 1]
          return true if entry.is_a?(Array)

          can_join_right?(entry)
        end

        def find_original_index(bases, shaped_bases, shaped_idx)
          orig = 0
          shaped = 0
          while shaped < shaped_idx && orig < bases.length
            orig += shaped_bases[shaped].is_a?(Array) ? 2 : 1
            shaped += 1
          end
          orig
        end

        def select_form(forms, prev_joins, next_joins)
          if prev_joins && next_joins && forms[3]
            forms[3]
          elsif prev_joins && forms[1]
            forms[1]
          elsif next_joins && forms[2]
            forms[2]
          else
            forms[0]
          end
        end
      end
    end
  end
end
