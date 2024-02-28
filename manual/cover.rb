# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Peritext.new do
  text do
    doc.move_down(200)

    doc.image(
      "#{Prawn::DATADIR}/images/prawn.png",
      scale: 0.9,
      at: [0, doc.cursor - 60],
    )

    doc.formatted_text_box(
      [{ text: "Prawn\n", font: 'DejaVu', styles: [:bold], size: 85 }],
      at: [160, doc.cursor - 50],
    )

    doc.formatted_text_box(
      [{ text: 'by example', font: 'Iosevka', size: 58 }],
      at: [165, doc.cursor - 130],
    )

    unless ENV['CI']
      git_commit =
        if Dir.exist?(File.expand_path('../.git', __dir__))
          commit = `git show --pretty=%h`
          "git commit: #{commit.lines.first}"
        else
          ''
        end

      doc.canvas do
        v_text = [
          {
            text: "Last Update: #{Time.now.strftime('%Y-%m-%d')}\n" \
              "Prawn Version: #{Prawn::VERSION}\n#{git_commit}",
            font: 'DejaVu',
            size: 12,
          },
        ]
        h = doc.height_of_formatted(v_text)

        doc.formatted_text_box(v_text, at: [370, h + 50])
      end
    end
  end
end
