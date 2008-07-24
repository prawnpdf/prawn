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

require 'ttf/datatypes'
require 'ttf/exceptions'
require 'ttf/fontchunk'
require 'ttf/encodings'

require 'ttf/table/cmap'
require 'ttf/table/cvt'
require 'ttf/table/fpgm'
require 'ttf/table/gasp'
require 'ttf/table/glyf'
require 'ttf/table/head'
require 'ttf/table/hhea'
require 'ttf/table/hmtx'
require 'ttf/table/kern'
require 'ttf/table/loca'
require 'ttf/table/maxp'
require 'ttf/table/name'
require 'ttf/table/os2'
require 'ttf/table/post'
require 'ttf/table/prep'
require 'ttf/table/vhea'
require 'ttf/table/vmtx'

module Font
module TTF
# TTF/Ruby is a library to read and write TrueType fonts in Ruby.
#
# Author:: Mathieu Blondel
# Copyright:: Copyright (c) 2006 Mathieu Blondel
# License:: GPL
#
# This Font::TTF::File class is TTF/Ruby's main class and is a subclass
# of Ruby's File class. Here is some sample code:
#
#  require 'ttf'
#
#  font = Font::TTF::File.new("copy.ttf")
#
#  cmap_tbl = font.get_table(:cmap)
#  enc_tbl4 = cmap_tbl.encoding_tables.find { |t| t.format == 4 }
#  m_unicode = "m".unpack("U")[0]
#  glyph_id = enc_tbl4.charmaps[m_unicode]
#
#  loca_tbl = font.get_table(:loca)
#  glyph_offset = loca_tbl.glyph_offsets[glyph_id]
#
#  glyf_tbl = font.get_table(:glyf)
#  glyph = glyf_tbl.get_glyph_at_offset(glyph_offset)
#  unless glyph.composite?
#      glyph.abs_coordinates.each { |x, y| puts x, y }
#  end
#
# Here are the tables and their associated Symbol:
#
# * :cmap => Font::TTF::Table::Cmap
# * :cvt => Font::TTF::Table::Cvt
# * :fpgm => Font::TTF::Table::Fpgm
# * :gasp => Font::TTF::Table::Gasp
# * :glyf => Font::TTF::Table::Glyf
# * :head => Font::TTF::Table::Head
# * :hhea => Font::TTF::Table::Hhea
# * :hmtx => Font::TTF::Table::Hmtx
# * :kern => Font::TTF::Table::Kern
# * :loca => Font::TTF::Table::Loca
# * :maxp => Font::TTF::Table::Maxp
# * :name => Font::TTF::Table::Name
# * :"OS/2" => Font::TTF::Table::OS2
# * :post => Font::TTF::Table::Post
# * :prep => Font::TTF::Table::Prep
# * :vhea => Font::TTF::Table::Vhea
# * :vmtx => Font::TTF::Table::Vmtx
# 
# Of course, you may modify attributes and generate a new font file.
#
#  require "ttf"
# 
#  font = Font::TTF::File.new("file.ttf", "w")
#  name_tbl = font.get_table(:name)
#  nr = name_tbl.name_records[0]
#  nr.utf8_str = "blablabla"
#  font.write(font.dump) 
#
class File < File

    TABLES = {:cmap => Font::TTF::Table::Cmap,
              :cvt => Font::TTF::Table::Cvt,
              :fpgm => Font::TTF::Table::Fpgm,
              :gasp => Font::TTF::Table::Gasp,
              :glyf => Font::TTF::Table::Glyf,
              :head => Font::TTF::Table::Head,
              :hhea => Font::TTF::Table::Hhea,
              :hmtx => Font::TTF::Table::Hmtx,
              :kern => Font::TTF::Table::Kern,
              :loca => Font::TTF::Table::Loca,
              :maxp => Font::TTF::Table::Maxp,
              :name => Font::TTF::Table::Name,
              :"OS/2" => Font::TTF::Table::OS2,
              :post => Font::TTF::Table::Post,
              :prep => Font::TTF::Table::Prep,
              :vhea => Font::TTF::Table::Vhea,
              :vmtx => Font::TTF::Table::Vmtx}

    DIR_ENTRY_SIZE = 4 * IO::SIZEOF_ULONG

    attr_reader :filename, :version, :search_range, 
                :entry_selector, :range_shift, :table_list, :tables_infos

    attr_writer :version, :search_range, :entry_selector, :range_shift

    # Font::TTF::File being a subclass of Ruby's File class, you may 
    # create new objects with the same parameters as Ruby's File class. 
    #
    # But you may also create new objects without parameters in case you want
    # to create a font from scratch and you don't need to write it to a file.
    def initialize(*args)
        if args.length == 0
            @filename = nil
            @version = 0x00010000 # 1.0
        else
            super(*args)
            @filename = args[0]
        end

        @table_list = [] # ordered list
        @tables = {} # Tables are kept in this arr so we don't
                     # have to create new objects everytime
        @tables_infos = {} # infos about tables present in file

        if not @filename.nil? and FileTest.exists? @filename    
            begin
                at_offset(0) do
                    @version = read_fixed
                    table_num = read_ushort
                    @search_range = read_ushort
                    @entry_selector = read_ushort
                    @range_shift = read_ushort                           
                
                    table_num.times do
                        tag = read_ulong_as_text.strip.to_sym
                        @table_list << tag
                        @tables_infos[tag] = {:checksum => read_ulong,
                                              :offset => read_ulong,
                                              :len => read_ulong}
                    end
                end               
            rescue
                raise MalformedFont
            end
        end
    end

    # Returns table associated with tag tbl_tag. It may return one of
    # Font::TTF::Table::* object or a Font::TTF::FontChunk object if the
    # table is not implemented yet by ttf-ruby.
    #
    # The table returned is kept internally so that every future call to
    # get_table with the same tbl_tag will return the same object.
    def get_table(tbl_tag)
        tbli = @tables_infos[tbl_tag]

        if @tables.include? tbl_tag
            @tables[tbl_tag]
        elsif tbli.nil?
            raise TableMissing, "Table #{tbl_tag.to_s} neither exists " + \
                                "in file nor was defined by user!"              
 
        elsif TABLES.include? tbl_tag
            @tables[tbl_tag] = \
                TABLES[tbl_tag].new(self, tbli[:offset], tbli[:len])
        else
            Font::TTF::FontChunk.new(self, tbli[:offset], tbli[:len])
        end
    end

    # Returns whether table with tag tbl_tag is already in font or not.
    def tables_include?(tbl_tag)
        @table_list.include? tbl_tag
    end

    # Gets a new empty table that then may be set with set_table.
    # tbl_tag is a Symbol.
    def get_new_table(tbl_tag)
        if TABLES.include? tbl_tag
            TABLES[tbl_tag].new(self)
        else
            Font::TTF::FontChunk.new(self)
        end
    end

    # Updates some member variables that change everytime a table is added
    # to the font.
    def table_list_update!
        @table_list.sort!

        res = 1
        power = 0
        while res <= @table_list.length
            res *= 2
            power += 1
        end
        @search_range = res * 16
        @entry_selector = power - 1
        @range_shift = @table_list.length * 16 - @search_range
    end
    private :table_list_update!

    # Adds tbl to font. tbl is a table object 
    # (e.g. an instance of Font::TTF::Table::Loca).
    def set_table(tbl)
        tbl_tag = tbl.tag

        unless tables_include? tbl_tag
            @table_list << tbl_tag 
            table_list_update!
        end
        @tables[tbl_tag] = tbl
    end
    
    # Removes tbl from font. tbl may be a Symbol (e.g. :loca for the loca table)
    # or a table object (e.g. an instance of Font::TTF::Table::Loca).
    def unset_table(tbl)
        if tbl.kind_of? Symbol
            tbl_tag = tbl
        else
            tbl_tag = tbl.tag
        end

        @table_list.delete(tbl_tag)
        @tables.delete(tbl_tag)
        table_list_update!
    end

    # Dumps the whole font in binary raw format as found in a font file.
    def dump
        raw = ""
        raw += (@version || 0).to_fixed
        raw += (@table_list || []).length.to_ushort
        raw += (@search_range || 0).to_ushort
        raw += (@entry_selector || 0).to_ushort
        raw += (@range_shift || 0).to_ushort

        
        offs = IO::SIZEOF_FIXED + 4 * IO::SIZEOF_USHORT + \
               @table_list.length * DIR_ENTRY_SIZE

        dumps = []
        @table_list.each do |tbl_tag|
            tbl = get_table(tbl_tag)
            tag = tbl_tag.to_s
            tag.four_chars!
            raw += tag
            # FIXME: FontChunk#checksum method is buggy
            # For now, I set it to 0
            raw += 0.to_ulong 
            raw += offs.to_ulong
            dump = tbl.dump
            dumps << dump
            len = dump.length
            raw += len.to_ulong
            offs += len
        end

        dumps.each do |dump|
            raw += dump
        end
        
        raw
    end

end

end
end