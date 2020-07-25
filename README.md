# Prawn: Fast, Nimble PDF Generation For Ruby

[![Gem Version](https://badge.fury.io/rb/prawn.svg)](http://badge.fury.io/rb/prawn)
[![Build Status](https://api.travis-ci.org/prawnpdf/prawn.svg?branch=master)](http://travis-ci.org/prawnpdf/prawn)
[![Code Climate](https://codeclimate.com/github/prawnpdf/prawn/badges/gpa.svg)](https://codeclimate.com/github/prawnpdf/prawn)
![Maintained: yes](https://img.shields.io/badge/maintained-yes-brightgreen.svg)

Prawn is a pure Ruby PDF generation library that provides a lot of great
functionality while trying to remain simple and reasonably performant. Here are
some of the important features we provide:

* Vector drawing support, including lines, polygons, curves, ellipses, etc.
* Extensive text rendering support, including flowing text and limited inline
  formatting options.
* Support for both PDF builtin fonts as well as embedded TrueType fonts
* A variety of low level tools for basic layout needs, including a simple grid
  system
* PNG and JPG image embedding, with flexible scaling options
* Security features including encryption and password protection
* Tools for rendering repeatable content (i.e headers, footers, and page
  numbers)
* Comprehensive internationalization features, including full support for UTF-8
  based fonts, right-to-left text rendering, fallback font support, and extension
  points for customizable text wrapping.
* Support for PDF outlines for document navigation
* Low level PDF features, allowing users to create custom extensions by dropping
  down all the way to the PDF object tree layer. (Mostly useful to those with
  knowledge of the PDF specification)
* Lots of other stuff!

## Should You Use Prawn?

If you are looking for a highly flexible PDF document generation system, Prawn
might be the tool for you. It is not a reporting tool or a publishing toolchain,
though it could be fairly easily used to build those things.

One thing Prawn is not, and will never be, is an HTML to PDF generator. For
those needs, consider looking into FlyingSaucer via JRuby, or one of the WebKit
based tools, like Wicked or PDFKit. We do have basic support for inline styling
but it is limited to a very small subset of functionality and is not suitable
for rendering rich HTML documents.

## Supported Ruby Versions and Implementations

Because Prawn is pure Ruby and all of its runtime dependencies are maintained by
us, it should work pretty much anywhere. We officially support all Ruby versions
suported by Ruby Core Team and JRuby versions of matching Ruby version. However
we will accept patches to fix problems on other Ruby platforms if they aren't
too invasive.

## Installing Prawn

Prawn is distributed via RubyGems, and can be installed the usual way that you
install gems: by simply typing `gem install prawn` on the command line.

You can also install from git if you'd like, the _master_ branch contains the
latest developments, and _stable_ represents the latest bug fixes to the
currently released version of Prawn. If you go this route, using Bundler is
encouraged.

## Hello World!

If the following code runs and produces a working PDF file, you've successfully
installed Prawn.

```ruby
require "prawn"

Prawn::Document.generate("hello.pdf") do
  text "Hello World!"
end
```

Of course, you'll probably want to do more interesting things than that...

## Manual

Felipe Doria provided us with a beautiful system for generating a user manual
from our examples. This can be generated from the prawn source or you can
download a pre-generated snapshot of it at http://prawnpdf.org/manual.pdf

Note that while we will try to keep the downloadable manual up to date, that
it's provided as a convenience only and you should generate the manual yourself
if you want to be sure the code in it actually runs and works as expected. To
build the manual, here's what you need to do:

1. Clone the repository
2. Switch to the stable branch (optional, stay on master for development
   version)
3. Run `gem install -g`
4. Run `rake manual`, which will generate _manual.pdf_ in the project root

## Release Policies

Before upgrading Prawn on one of your projects, you should read our [API
compatibility](https://github.com/prawnpdf/prawn/wiki/API-Compatibility-Notes)
guidelines. Generally speaking, you can expect tiny and minor version updates to
always be safe upgrades, but major updates can introduce incompatibilities.

Be sure to read the release notes in
[CHANGELOG.md](https://github.com/prawnpdf/prawn/blob/master/CHANGELOG.md) each
time we cut a new release, and lock your gems accordingly.

## Support

The easiest way to get help with Prawn is to post a message to our mailing list:

<http://groups.google.com/group/prawn-ruby>

Feel free to post any Prawn related question there, our community is very
responsive and will be happy to help you figure out how to use Prawn, or help
you determine whether it's the right tool for the task you are working on.

Please make your posts to the list as specific as possible, including code
samples and output where relevant. Do not post any information that should not
be shared publicly, and be sure to reduce your example code as much as possible
so that those who are responding to your question can more easily see what the
issue might be.

## Code of Conduct
Prawn adheres to the [Contributor Covenant](CODE_OF_CONDUCT.md).
Unacceptable behavior can be reported to conduct@prawnpdf.org which is monitored
by the core team.


## Contributing

If you've found a bug or want to submit a patch, please enter a ticket into our
[GitHub tracker](http://github.com/prawnpdf/prawn/issues).

We strongly encourage bug reports to come with failing tests or at least a
reduced example that demonstrates the problem. Similarly, patches should include
tests, API documentation, and an update to the manual where relevant. Feel free
to send a pull request early though, if you just want some feedback or a code
review before preparing your code to be merged.

If you are unsure about whether or not you've found a bug, or want to check to
see whether we'd be interested in the feature you want to add before you start
working on it, feel free to post to our mailing list.

You can run our test suite in a few different ways:

1. Running `rake` will run the entire test suite excluding any unresolved issues
2. Running `rspec` will run the entire test suite including unresolved issues
3. Running `rspec -t unresolved` will run *only* unresolved issues
4. Running `rspec -t issue:NUMBER` will run the tests for a specific issue

These filters make it possible for us to add failing test cases for bugs that
are currently being researched or worked on, without breaking the typical full
suite run.

## Maintenance team

Prawn has always been heavily dependent on community contributions, with dozens
of people contributing code over the year. In that sense, the lines have blurred
to the point where we no longer have a strong distinction between core
developers and contributors.

That said, there are a few folks who have been responsible for cutting releases,
merging important pull requests, and making major decisions about the overall
direction of the project.

### Current maintainers

These are the folks to contact if you have a maintenance-related issue with
Prawn:

* Alexander Mankuta ([PointlessOne](https://github.com/PointlessOne))

### Inactive maintainers

These folks have helped out in a maintenance role in the past, but are no longer
actively involved in the project:

* Gregory Brown ([practicingruby](https://github.com/practicingruby))
* Brad Ediger ([bradediger](https://github.com/bradediger))
* James Healy ([yob](https://github.com/yob))
* Daniel Nelson ([Bluejade](https://github.com/Bluejade))
* Jonathan Greenberg ([jonsgreen](https://github.com/jonsgreen))
* Jamis Buck ([jamis](https://github.com/jamis))
* Evan Sharp ([PacketMonkey](https://github.com/PacketMonkey))

## License

Prawn is released under a slightly modified form of the License of Ruby,
allowing you to choose between Matz's terms, the GPLv2, or GPLv3. For details,
please see the LICENSE, GPLv2, and GPLv3 files.

If you contribute to Prawn, you will retain your own copyright but must agree to
license your code under the same terms as the project itself.

## History

Prawn was originally developed by [Gregory
Brown](http://twitter.com/practicingruby), under the auspices of the Ruby
Mendicant Project, a grassroots initiative in which the Ruby community
collectively provided funding so that Gregory could take several months off from
work to focus on this project.

Over the last several years, we've received code contributions from dozens of
people, which is amazing considering the low-level nature of this project. You
can find the full list of folks who have at least one patch accepted to Prawn on
GitHub [Contributors](https://github.com/prawnpdf/prawn/contributors) page.

After a long period of inactivity, Prawn reached its 1.0 milestone in 2014
thanks to some modest funding provided to Gregory by Madriska, Inc. (Brad
Ediger's company).
