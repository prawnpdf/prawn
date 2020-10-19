# frozen_string_literal: true

require 'spec_helper'

describe Prawn::Outline do
  let(:pdf) do
    Prawn::Document.new do
      text 'Page 1. This is the first Chapter. '
      start_new_page
      text 'Page 2. More in the first Chapter. '
      start_new_page
      outline.define do
        section 'Chapter 1', destination: 1, closed: true do
          page destination: 1, title: 'Page 1'
          page destination: 2, title: 'Page 2'
        end
      end
    end
  end

  let(:hash) do
    output = StringIO.new(pdf.render, 'r+')
    PDF::Reader::ObjectHash.new(output)
  end
  let(:outline_root) do
    hash.values.find do |obj|
      obj.is_a?(Hash) && obj[:Type] == :Outlines
    end
  end

  describe 'outline encoding' do
    it 'stores all outline titles as UTF-16' do
      hash.each_value do |obj|
        next unless obj.is_a?(Hash) && obj[:Title]

        title = obj[:Title].dup
        title.force_encoding(Encoding::UTF_16LE)
        expect(title.valid_encoding?).to eq(true)
      end
    end
  end

  describe '#generate_outline' do
    it 'creates a root outline dictionary item' do
      expect(outline_root).to_not be_nil
    end

    it 'sets the first and last top items of the root outline dictionary '\
      'item' do
      section1 = find_by_title('Chapter 1')

      expect(referenced_object(outline_root[:First])).to eq(section1)
      expect(referenced_object(outline_root[:Last])).to eq(section1)
    end

    describe '#create_outline_item' do
      it 'creates outline items for each section and page' do
        section1 = find_by_title('Chapter 1')
        page1 = find_by_title('Page 1')
        page2 = find_by_title('Page 2')

        expect(section1).to_not be_nil
        expect(page1).to_not be_nil
        expect(page2).to_not be_nil
      end
    end

    describe '#set_relations, #set_variables_for_block, and #reset_parent' do
      it 'links sibling items' do
        page1 = find_by_title('Page 1')
        page2 = find_by_title('Page 2')

        expect(referenced_object(page1[:Next])).to eq(page2)
        expect(referenced_object(page2[:Prev])).to eq(page1)
      end

      it 'links child items to parent item' do
        section1 = find_by_title('Chapter 1')
        page1 = find_by_title('Page 1')
        page2 = find_by_title('Page 2')

        expect(referenced_object(page1[:Parent])).to eq(section1)
        expect(referenced_object(page2[:Parent])).to eq(section1)
      end

      it 'sets the first and last child items for parent item' do
        section1 = find_by_title('Chapter 1')
        page1 = find_by_title('Page 1')
        page2 = find_by_title('Page 2')

        expect(referenced_object(section1[:First])).to eq(page1)
        expect(referenced_object(section1[:Last])).to eq(page2)
      end
    end

    describe '#increase_count' do
      it 'adds the count of all descendant items' do
        section1 = find_by_title('Chapter 1')
        page1 = find_by_title('Page 1')
        page2 = find_by_title('Page 2')

        expect(outline_root[:Count]).to eq(3)
        expect(section1[:Count].abs).to eq(2)
        expect(page1[:Count]).to eq(0)
        expect(page2[:Count]).to eq(0)
      end
    end

    describe 'closed option' do
      it "sets the item's integer count to negative" do
        section1 = find_by_title('Chapter 1')

        expect(section1[:Count]).to eq(-2)
      end
    end
  end

  describe 'adding a custom destination' do
    before do
      pdf.start_new_page
      pdf.text 'Page 3 with a destination'
      pdf.add_dest('customdest', pdf.dest_xyz(200, 200))
      destination = pdf.dest_xyz(200, 200)
      pdf.outline.update do
        page destination: destination, title: 'Custom Destination'
      end
    end

    it 'creates an outline item' do
      custom_dest = find_by_title('Custom Destination')

      expect(custom_dest).to_not be_nil
    end

    it 'references the custom destination' do
      custom_dest = find_by_title('Custom Destination')
      last_page =
        hash.values.find do |obj|
          obj.is_a?(Hash) && obj[:Type] == :Pages
        end[:Kids]
          .last

      expect(referenced_object(custom_dest[:Dest].first))
        .to eq(referenced_object(last_page))
    end
  end

  describe 'addding a section later with outline#section' do
    before do
      pdf.start_new_page
      pdf.text 'Page 3. An added section '
      pdf.outline.update do
        section 'Added Section', destination: 3 do
          page destination: 3, title: 'Page 3'
        end
      end
    end

    it 'adds new outline items to document' do
      section2 = find_by_title('Added Section')
      page3 = find_by_title('Page 3')

      expect(section2).to_not be_nil
      expect(page3).to_not be_nil
    end

    it 'resets the last items for root outline dictionary' do
      section1 = find_by_title('Chapter 1')
      section2 = find_by_title('Added Section')

      expect(referenced_object(outline_root[:First])).to eq(section1)
      expect(referenced_object(outline_root[:Last])).to eq(section2)
    end

    it 'resets the next relation for the previous last top level item' do
      section1 = find_by_title('Chapter 1')
      section2 = find_by_title('Added Section')

      expect(referenced_object(section1[:Next])).to eq(section2)
    end

    it 'sets the previous relation of the addded to section' do
      section1 = find_by_title('Chapter 1')
      section2 = find_by_title('Added Section')

      expect(referenced_object(section2[:Prev])).to eq(section1)
    end

    it 'increases the count of root outline dictionary' do
      expect(outline_root[:Count]).to eq(5)
    end
  end

  describe '#outline.add_subsection_to' do
    context 'when positioned last' do
      before do
        pdf.start_new_page
        pdf.text 'Page 3. An added subsection '
        pdf.outline.update do
          add_subsection_to 'Chapter 1' do
            section 'Added SubSection', destination: 3 do
              page destination: 3, title: 'Added Page 3'
            end
          end
        end
      end

      it 'adds new outline items to document' do
        subsection = find_by_title('Added SubSection')
        added_page = find_by_title('Added Page 3')

        expect(subsection).to_not be_nil
        expect(added_page).to_not be_nil
      end

      it 'resets the last item for parent item dictionary' do
        section1 = find_by_title('Chapter 1')
        page1 = find_by_title('Page 1')
        subsection = find_by_title('Added SubSection')

        expect(referenced_object(section1[:First])).to eq(page1)
        expect(referenced_object(section1[:Last])).to eq(subsection)
      end

      it "sets the prev relation for the new subsection to its parent's old "\
        'last item' do
        subsection = find_by_title('Added SubSection')
        page2 = find_by_title('Page 2')

        expect(referenced_object(subsection[:Prev])).to eq(page2)
      end

      it "the subsection should become the next relation for its parent's old "\
        'last item' do
        subsection = find_by_title('Added SubSection')
        page2 = find_by_title('Page 2')

        expect(referenced_object(page2[:Next])).to eq(subsection)
      end

      it 'sets the first relation for the new subsection' do
        subsection = find_by_title('Added SubSection')
        added_page = find_by_title('Added Page 3')

        expect(referenced_object(subsection[:First])).to eq(added_page)
      end

      it 'sets the correct last relation of the added to section' do
        subsection = find_by_title('Added SubSection')
        added_page = find_by_title('Added Page 3')

        expect(referenced_object(subsection[:Last])).to eq(added_page)
      end

      it 'increases the count of root outline dictionary' do
        expect(outline_root[:Count]).to eq(5)
      end
    end

    context 'when positioned first' do
      before do
        pdf.start_new_page
        pdf.text 'Page 3. An added subsection '
        pdf.outline.update do
          add_subsection_to 'Chapter 1', :first do
            section 'Added SubSection', destination: 3 do
              page destination: 3, title: 'Added Page 3'
            end
          end
        end
      end

      it 'adds new outline items to document' do
        subsection = find_by_title('Added SubSection')
        added_page = find_by_title('Added Page 3')

        expect(subsection).to_not be_nil
        expect(added_page).to_not be_nil
      end

      it 'resets the first item for parent item dictionary' do
        section1 = find_by_title('Chapter 1')
        subsection = find_by_title('Added SubSection')
        page2 = find_by_title('Page 2')

        expect(referenced_object(section1[:First])).to eq(subsection)
        expect(referenced_object(section1[:Last])).to eq(page2)
      end

      it "sets the next relation for the new subsection to its parent's old "\
        'first item' do
        subsection = find_by_title('Added SubSection')
        page1 = find_by_title('Page 1')

        expect(referenced_object(subsection[:Next])).to eq(page1)
      end

      it "the subsection should become the prev relation for its parent's old "\
        'first item' do
        subsection = find_by_title('Added SubSection')
        page1 = find_by_title('Page 1')

        expect(referenced_object(page1[:Prev])).to eq(subsection)
      end

      it 'sets the first relation for the new subsection' do
        subsection = find_by_title('Added SubSection')
        added_page = find_by_title('Added Page 3')

        expect(referenced_object(subsection[:First])).to eq(added_page)
      end

      it 'sets the correct last relation of the added to section' do
        subsection = find_by_title('Added SubSection')
        added_page = find_by_title('Added Page 3')

        expect(referenced_object(subsection[:Last])).to eq(added_page)
      end

      it 'increases the count of root outline dictionary' do
        expect(outline_root[:Count]).to eq(5)
      end
    end

    it 'requires an existing title' do
      expect do
        pdf.go_to_page 1
        pdf.start_new_page
        pdf.text 'Inserted Page'
        pdf.outline.update do
          add_subsection_to 'Wrong page' do
            page page_number, title: 'Inserted Page'
          end
        end
        render_and_find_objects
      end.to raise_error(Prawn::Errors::UnknownOutlineTitle)
    end
  end

  describe '#outline.insert_section_after' do
    describe 'inserting in the middle of another section' do
      before do
        pdf.go_to_page 1
        pdf.start_new_page
        pdf.text 'Inserted Page'
        pdf.outline.update do
          insert_section_after 'Page 1' do
            page destination: page_number, title: 'Inserted Page'
          end
        end
      end

      it 'inserts new outline items to document' do
        inserted_page = find_by_title('Inserted Page')

        expect(inserted_page).to_not be_nil
      end

      it 'adjusts the count of all ancestors' do
        section1 = find_by_title('Chapter 1')

        expect(outline_root[:Count]).to eq(4)
        expect(section1[:Count].abs).to eq(3)
      end

      describe '#adjust_relations' do
        it 'resets the sibling relations of adjoining items to inserted item' do
          inserted_page = find_by_title('Inserted Page')
          page1 = find_by_title('Page 1')
          page2 = find_by_title('Page 2')

          expect(referenced_object(page1[:Next])).to eq(inserted_page)
          expect(referenced_object(page2[:Prev])).to eq(inserted_page)
        end

        it 'sets the sibling relation of added item to adjoining items' do
          inserted_page = find_by_title('Inserted Page')
          page1 = find_by_title('Page 1')
          page2 = find_by_title('Page 2')

          expect(referenced_object(inserted_page[:Next])).to eq(page2)
          expect(referenced_object(inserted_page[:Prev])).to eq(page1)
        end

        it 'does not affect the first and last relations of parent item' do
          section1 = find_by_title('Chapter 1')
          page1 = find_by_title('Page 1')
          page2 = find_by_title('Page 2')

          expect(referenced_object(section1[:First])).to eq(page1)
          expect(referenced_object(section1[:Last])).to eq(page2)
        end
      end

      context 'when adding another section afterwards' do
        it 'has reset the root position so that a new section is added at '\
          'the end of root sections' do
          pdf.start_new_page
          pdf.text 'Another Inserted Page'
          pdf.outline.update do
            section 'Added Section' do
              page destination: page_number, title: 'Inserted Page'
            end
          end

          section1 = find_by_title('Chapter 1')
          section2 = find_by_title('Added Section')

          expect(referenced_object(outline_root[:Last])).to eq(section2)
          expect(referenced_object(section1[:Next])).to eq(section2)
        end
      end
    end

    describe 'inserting at the end of another section' do
      before do
        pdf.go_to_page 2
        pdf.start_new_page
        pdf.text 'Inserted Page'
        pdf.outline.update do
          insert_section_after 'Page 2' do
            page destination: page_number, title: 'Inserted Page'
          end
        end
      end

      describe '#adjust_relations' do
        it 'resets the sibling relations of adjoining item to inserted item' do
          page2 = find_by_title('Page 2')
          inserted_page = find_by_title('Inserted Page')

          expect(referenced_object(page2[:Next])).to eq(inserted_page)
        end

        it 'sets the sibling relation of added item to adjoining items' do
          page2 = find_by_title('Page 2')
          inserted_page = find_by_title('Inserted Page')

          expect(referenced_object(inserted_page[:Next])).to be_nil
          expect(referenced_object(inserted_page[:Prev])).to eq(page2)
        end

        it 'adjusts the last relation of parent item' do
          section1 = find_by_title('Chapter 1')
          inserted_page = find_by_title('Inserted Page')

          expect(referenced_object(section1[:Last])).to eq(inserted_page)
        end
      end
    end

    it 'requires an existing title' do
      expect do
        pdf.go_to_page 1
        pdf.start_new_page
        pdf.text 'Inserted Page'
        pdf.outline.update do
          insert_section_after 'Wrong page' do
            page destination: page_number, title: 'Inserted Page'
          end
        end
      end.to raise_error(Prawn::Errors::UnknownOutlineTitle)
    end
  end

  describe '#page' do
    it 'requires a title option to be set' do
      expect do
        Prawn::Document.new do
          text 'Page 1. This is the first Chapter. '
          outline.define do
            page destination: 1, title: nil
          end
        end
      end.to raise_error(Prawn::Errors::RequiredOption)
    end
  end

  describe 'foreign character encoding' do
    let(:hash) do
      pdf =
        Prawn::Document.new do
          outline.define do
            section 'La pomme croquée', destination: 1, closed: true
          end
        end
      PDF::Reader::ObjectHash.new(StringIO.new(pdf.render, 'r+'))
    end

    it 'handles other encodings for the title' do
      object = find_by_title('La pomme croquée')
      expect(object).to_not be_nil
    end
  end

  # Outline titles are stored as UTF-16. This method accepts a UTF-8 outline
  # title and returns the PDF Object that contains an outline with that name
  def find_by_title(title)
    hash.values.find do |obj|
      next unless obj.is_a?(Hash) && obj[:Title]

      title_codepoints = obj[:Title].unpack('n*')
      title_codepoints.shift
      utf8_title = title_codepoints.pack('U*')
      utf8_title == title ? obj : nil
    end
  end

  def referenced_object(reference)
    hash[reference]
  end
end
