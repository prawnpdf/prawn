# encoding: utf-8
#
# Prawn manual how to read this manual page.
#

require_relative "example_helper"

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::ManualBuilder::Example.generate(filename) do
  move_down 200

  image "#{Prawn::DATADIR}/images/prawn.png",
        :scale => 0.9,
        :at => [10, cursor]

  formatted_text_box([ {:text => "Prawn\n",
                        :styles => [:bold],
                        :size => 100}
                     ], :at => [170, cursor - 50])

  formatted_text_box([ {:text => "by example",
                        :font => 'Courier',
                        :size => 60}
                     ], :at => [170, cursor - 160])

  if Dir.exist?("#{Prawn::BASEDIR}/.git")
    #long git commit hash
    #commit = `git show --pretty=%H`
    #short git commit hash
    commit = `git show --pretty=%h`
    git_commit = "git commit: #{commit}"
  else
    git_commit = ""
  end

  formatted_text_box([  {:text => "Last Update: #{Time.now.strftime("%Y-%m-%d")}\n"+
                                  "Prawn Version: #{Prawn::VERSION}\n"+
                                  git_commit,
                         :size => 12}
                    ],   :at => [390, cursor - 620])

end
