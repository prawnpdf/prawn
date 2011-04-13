# encoding: utf-8
#
# forms.rb : Provides methods for filling PDF forms
#
# Copyright 2011 Infonium Inc. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn

  # The Prawn::Forms module is used to allow introspecting and filling PDF
  # forms with user-supplied data.  PDF forms can be created using external
  # tools like OpenOffice.org or Adobe Acrobat.
  #
  # Example:
  #
  #   Prawn::Document.generate("out.pdf", :template => "data/pdfs/form_with_annotations.pdf") do |pdf|
  #     foo = pdf.form_fields # => ['name', 'quest']
  #     pdf.fill_form "name" => "Sir Launcelot", "quest" => "To find the Grail"
  #   end
  #
  module Forms
    # Return a list of form field names that may be populated using fill_form
    def form_fields
      specs = form_field_specs
      return [] unless specs
      specs.keys
    end

    # Populate the form fields
    def fill_form(hash={})
      specs = form_field_specs
      return unless specs
      specs.each_pair do |name, spec|
        value = hash[name] || spec[:default_value]
        x = [spec[:box][0], spec[:box][2]].min
        y = [spec[:box][1], spec[:box][3]].min

        # Draw the text.
        # TODO: Fill the form precisely, according to the PDF spec.  This code
        # currently just draws text at the specified locations on each form.
        # Attributes like font and font size are not respected.
        saved_page_number = page_number
        go_to_page(spec[:page_number])
        float do
          canvas do
            draw_text value, :at => [x, y]
          end
        end
        go_to_page(saved_page_number)

        # Remove form field annotation
        spec[:refs][:acroform_fields].delete(spec[:refs][:field])
        deref(deref(spec[:refs][:page])[:Annots]).delete(spec[:refs][:field])
      end
      nil
    end

    private

    # Return a Hash of information about form fields that may be populated using fill_form
    def form_field_specs
      page_numbers = {}
      state.pages.each_with_index do |page, i|
        page_numbers[page.dictionary] = i+1
      end
      root = deref(state.store.root)
      acro_form = deref(root[:AcroForm])
      return nil unless acro_form
      form_fields = deref(acro_form[:Fields])
      Hash[form_fields.map do |field_ref|
        field_dict = deref(field_ref)
        next unless deref(field_dict[:Type]) == :Annot and deref(field_dict[:Subtype]) == :Widget
        next unless deref(field_dict[:FT]) == :Tx
        name = string_to_utf8(deref(field_dict[:T]))
        spec = {}
        spec[:box] = deref(field_dict[:Rect])
        spec[:default_value] = string_to_utf8(deref(field_dict[:V] || field_dict[:DV]))
        spec[:page_number] = page_numbers[field_dict[:P]]
        spec[:refs] = {
          :page => field_dict[:P],
          :field => field_ref,
          :acroform_fields => form_fields,
        }
        [name, spec]
      end]
    end

    def string_to_utf8(str)
      str = str.dup
      str.force_encoding("ASCII-8BIT") if str.respond_to?(:force_encoding)
      if str =~ /\A\xFE\xFF/n
        utf16_to_utf8(str)
      else
        str
      end
    end
  end
end
