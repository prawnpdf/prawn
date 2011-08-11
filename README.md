# Prawn: Fast, Nimble PDF Generation For Ruby

Prawn is a pure Ruby PDF generation library that provides a lot of great functionality while trying to remain simple and reasonably performant. Here are some of the important features we provide:

* Vector drawing support, including lines, polygons, curves, ellipses, etc.
* Extensive text rendering support, including flowing text and limited inline formatting options. 
* Support for both PDF builtin fonts as well as embedded TrueType fonts
* A variety of low level tools for basic layout needs, including a simple grid system
* PNG and JPG image embedding, with flexible scaling options
* Reporting tools for rendering complex data tables, with pagination support
* Security features including encryption and password protection
* Tools for rendering repeatable content (i.e headers, footers, and page numbers)
* Comprehensive internationalization features, including full support for UTF-8 based fonts, right-to-left text rendering, fallback font support, and extension points for customizable text wrapping.
* Support for PDF outlines for document navigation
* Low level PDF features, allowing users to create custom extensions by dropping down all the way to the PDF object tree layer. (Mostly useful to those with knowledge of the PDF specification)
* Lots of other stuff!

## Should You Use Prawn?

If you are looking for a highly flexible PDF document generation system, Prawn might be the tool for you. It is not a reporting tool or a publishing toolchain, though it could be fairly easily used to build those things.

One thing Prawn is not, and will never be, is an HTML to PDF generator. For those needs, consider looking into FlyingSaucer via JRuby, or one of the webkit based tools, like Wicked or PDFKit. We do have basic support for inline styling but it is limited to a very small subset of functionality and is not suitable for rendering rich HTML documents.

## Supported Ruby Versions and Implementations

Because Prawn is pure Ruby and virtually all of its dependencies are maintained by our core team, it should run pretty much anywhere, including Rubinius, JRuby, MacRuby, etc. While we officially support MRI 1.8.7 and 1.9.2 only, we will accept patches to fix problems on other Ruby platforms if they aren't too invasive.

## Installing Prawn

Prawn is distributed via RubyGems, and can be installed the usual way that you install gems: by simply typing `gem install prawn` on the command line. 

You can also install from git if you'd like, the _master_ branch contains the latest developments, and _stable_ represents the latest bug fixes to the currently released version of Prawn. If you go this route, using Bundler is encouraged.

## Release Policies

We may introduce backwards incompatible changes each time our minor version number is bumped, but that any tiny version number bump should be bug fixes and internal changes only. Be sure to read the release notes each time we cut a new release and lock your gems accordingly. You can find the project CHANGELOG at: https://github.com/sandal/prawn/wiki/CHANGELOG

## Hello World!

If the following code runs and produces a working PDF file, you've successfully installed Prawn.

    require "prawn"

    Prawn::Document.generate("hello.pdf") do
      text "Hello World!"
    end

Of course, you'll probably want to do more interesting things than that...

## Manual

Mendicant University student Felipe Doria provided us with a beautiful system for generating a user manual from our examples. This can be generated from the prawn source or you can download a pre-generated snapshot of it at http://prawn.majesticseacreature.com/manual.pdf

Note that while we will try to keep the downloadable manual up to date, that it's provided as a convenience only and you should generate the manual yourself if you want to be sure the code in it actually runs and works as expected. To build the manual, here's what you need to do:

1. clone the repository
2. switch to the stable branch (optional, stay on master for development version)
3. install bundler if necessay
4. run `bundle install`
5. run `bundle exec rake manual`, which will generate _manual.pdf_ in the project root

## Support 

The easiest way to get help with Prawn is to post a message to our mailing list:

<http://groups.google.com/group/prawn-ruby>

Feel free to post any Prawn related question there, our community is very responsive and will be happy to help you figure out how to use Prawn, or help you determine whether it's the right tool for the task you are working on.

Please make your posts to the list as specific as possible, including code samples and output where relevant. Do not post any information that should not be shared publicly, and be sure to reduce your example code as much as possible so that those who are responding to your question can more easily see what the issue might be.

## Contributing

If you've found a bug, want to submit a patch, or have a feature request, please enter a ticket into our github tracker:

<http://github.com/sandal/prawn/issues>

We strongly encourage bug reports to come with failing tests or at least a reduced example that demonstrates the problem. Similarly, patches should include tests, API documentation, and an update to the manual where relevant. Feel free to send a pull request early though, if you just want some feedback or a code review before preparing your code to be merged.

If you are unsure about whether or not you've found a bug, or want to check to see whether we'd be interested in the feature you want to add before you start working on it, feel free to post to our mailing list.

## Authorship

Prawn was originally developed by Gregory Brown, under the auspices of the Ruby Mendicant Project, a grassroots initiative in which the Ruby community collectively provided funding so that Gregory could take several months off of work to focus on this project.

Over the last several years, we've received code contributions from over 50 people, which is amazing considering the low-level nature of this project. In 2010, Gregory officially handed the project off to the Prawn core team. Currently active maintainers include Brad Ediger, Daniel Nelson, James Healy, and Jonathan Greenberg.

While he was only with us for a short time before moving on to other things, we'd also like to thank Prawn core team emeritus Jamis Buck for his contributions. He was responsible for introducing font subsetting as well as the first implementation of our inline formatting support.

You can find the full list of folks who have at least one patch accepted to Prawn on github at https://github.com/sandal/prawn/contributors

## License

Prawn is released under a slightly modified form of the License of Ruby, allowing you to choose between Matz's terms, the GPLv2, or GPLv3. For details, please see the LICENSE, GPLv2, and GPLv3 files.

If you wish to contribute to Prawn, you will retain your own copyright but must agree to license your code under the same terms as the project itself.
