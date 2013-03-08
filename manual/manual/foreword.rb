# encoding: utf-8
#
# Prawn manual foreword page.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  header("Foreword, by Gregory Brown")
  prose %{
    Back in 2008, the state of PDF generation in
    Ruby was grim. The best general purpose tool that existed was
    Austin Ziegler's PDF::Writer, which was an ambitious but
    painfully unsustainable project. Despite years of hard work
    from Austin, the code was slow, buggy, and hard to
    understand. All of those things made it very difficult
    to extend with the many features that its users needed,
    and so it gradually turned into abandonware.

    Because I had a lot of work that depended on PDF generation
    I eventually volunteered to become the new maintainer of
    PDF::Writer. In the first couple months after I got commit bit, I
    managed to get out a couple minor releases that fixed
    known issues that had been left unresolved for years,
    and that made some people happy. However, the cliff
    ahead of me was far too steep to climb: without a
    major redesign, PDF::Writer would never support proper
    internationalization, would not easily be ported to
    Ruby 1.9, and would remain painfully slow for many
    ordinary tasks.

    Against my better judgement, but out of desperation, I
    was convinced that the only way forward was to attempt the
    big rewrite. It is good that I didn't realize
    how impossible that task would be, because otherwise,
    I would have never started working
    on Prawn. But with the support of dozens of Ruby community
    members who had graciously crowd-funded this project
    so that I could take a few months off of work to
    kick start it (long before Kickstarter existed!), Prawn
    was born.

    The PDF specification is over 1300 pages long, and despite
    being the original author and lead maintainer of this
    project from 2008-2011, I still know relatively little
    about the intricacies of the format. I relied heavily
    on the insights of our core team and casual contributors
    to educate me on various issues, and to help develop
    nearly every feature of this project. From day one,
    Prawn was a stone soup in which virtually all of the
    tasty bits were provided by the community at large --
    my most significant contribution was to simply
    keep stirring the pot. Now, the pot mostly stirs itself,
    with the occasional nudge from one of the core
    team members (usually Brad or James, but everyone
    has pitched in at one time or the other.)

    Although Prawn bears no resemblance to PDF::Writer, this library
    is most certainly its spiritual successor. That means that between
    Austin's efforts and that of the Prawn team, we've been
    trying to solve the PDF problem comfortably in Ruby for
    nearly a decade now. This manual will help you decide for
    yourself whether we've managed to finally overcome that
    challenge or not.

    I sincerely hope that a few years down the line, someone else
    comes along and makes something brand new and exciting that
    blows Prawn out of the water and onto the barbeque. But until
    that happens, what you'll find here is a very powerful
    PDF generation library that has a great team supporting it,
    and I suspect it will stay that way for the forseeable future.

    Happy Hacking!

    -greg

    PS: I cannot be possibly be more grateful for the time, money,
    code, and knowledge that the Ruby community has invested in
    this project. Whether you're a core team member or someone
    who filed a single thoughtful bug report, your efforts are
    what kept me motivated throughout the years that I spent working
    on this project.
  }
end
