# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Manual.new(__dir__, page_size: 'A4') do
  part 'cover'
  part 'how_to_read_this_manual'

  # Core chapters

  section 'Basic Concepts' do
    part 'basic_concepts'
    chapter 'basic_concepts/creation'
    chapter 'basic_concepts/origin'
    chapter 'basic_concepts/cursor'
    chapter 'basic_concepts/other_cursor_helpers'
    chapter 'basic_concepts/adding_pages'
    chapter 'basic_concepts/measurement'
    chapter 'basic_concepts/view'
  end

  section 'Graphics' do
    part 'graphics'

    section 'Basics' do
      chapter 'graphics/helper'
      chapter 'graphics/fill_and_stroke'
    end

    section 'Shapes' do
      chapter 'graphics/lines_and_curves'
      chapter 'graphics/common_lines'
      chapter 'graphics/rectangle'
      chapter 'graphics/polygon'
      chapter 'graphics/circle_and_ellipse'
    end

    section 'Fill and Stroke Settings' do
      chapter 'graphics/line_width'
      chapter 'graphics/stroke_cap'
      chapter 'graphics/stroke_join'
      chapter 'graphics/stroke_dash'
      chapter 'graphics/color'
      chapter 'graphics/gradients'
      chapter 'graphics/transparency'
      chapter 'graphics/soft_masks'
      chapter 'graphics/blend_mode'
      chapter 'graphics/fill_rules'
    end

    section 'Transformations' do
      chapter 'graphics/rotate'
      chapter 'graphics/translate'
      chapter 'graphics/scale'
    end
  end

  section 'Text' do
    part 'text'

    section 'Basics' do
      chapter 'text/free_flowing_text'
      chapter 'text/positioned_text'
      chapter 'text/text_box_overflow'
      chapter 'text/text_box_excess'
      chapter 'text/column_box'
    end

    section 'Styling' do
      chapter 'text/font'
      chapter 'text/font_size'
      chapter 'text/font_style'
      chapter 'text/color'
      chapter 'text/alignment'
      chapter 'text/leading'
      chapter 'text/kerning_and_character_spacing'
      chapter 'text/paragraph_indentation'
      chapter 'text/rotation'
    end

    section 'Advanced Styling' do
      chapter 'text/inline'
      chapter 'text/formatted_text'
      chapter 'text/formatted_callbacks'
      chapter 'text/rendering_and_color'
      chapter 'text/text_box_extensions'
    end

    section 'External Fonts' do
      chapter 'text/single_usage'
      chapter 'text/registering_families'
    end

    section 'Multilingualization' do
      chapter 'text/utf8'
      chapter 'text/line_wrapping'
      chapter 'text/right_to_left_text'
      chapter 'text/fallback_fonts'
      chapter 'text/win_ansi_charset'
    end
  end

  section 'Bounding Box' do
    part 'bounding_box'

    section 'Basics' do
      chapter 'bounding_box/creation'
      chapter 'bounding_box/bounds'
    end

    section 'Advanced' do
      chapter 'bounding_box/stretchy'
      chapter 'bounding_box/nesting'
      chapter 'bounding_box/indentation'
      chapter 'bounding_box/canvas'
      chapter 'bounding_box/recursive_boxes'
    end
  end

  # Remaining chapters

  section 'Layout' do
    part 'layout'

    chapter 'layout/simple_grid'
    chapter 'layout/boxes'
    chapter 'layout/content'
  end

  chapter 'table'

  section 'Images' do
    part 'images'

    section 'Basics' do
      chapter 'images/plain_image'
      chapter 'images/absolute_position'
    end

    section 'Relative Positioning' do
      chapter 'images/horizontal'
      chapter 'images/vertical'
    end

    section 'Size' do
      chapter 'images/width_and_height'
      chapter 'images/scale'
      chapter 'images/fit'
    end
  end

  section 'Document and Page Options' do
    part 'document_and_page_options'

    chapter 'document_and_page_options/page_size'
    chapter 'document_and_page_options/page_margins'
    chapter 'document_and_page_options/background'
    chapter 'document_and_page_options/metadata'
    chapter 'document_and_page_options/print_scaling'
  end

  section 'Outline' do
    part 'outline'

    section 'Basics' do
      chapter 'outline/sections_and_pages'
    end

    section 'Adding Nodes Later' do
      chapter 'outline/add_subsection_to'
      chapter 'outline/insert_section_after'
    end
  end

  section 'Repeatable Content' do
    part 'repeatable_content'

    chapter 'repeatable_content/repeater'
    chapter 'repeatable_content/stamp'
    chapter 'repeatable_content/page_numbering'
    chapter 'repeatable_content/alternate_page_numbering'
  end

  section 'Security' do
    part 'security'

    chapter 'security/encryption'
    chapter 'security/permissions'
  end
end
