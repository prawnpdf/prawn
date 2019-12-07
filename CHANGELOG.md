## PrawnPDF master branch

### Added documentation about document configuration with `Prawn::View`

(Arnaud Joubay, [#1112](https://github.com/prawnpdf/prawn/pull/1112))

### Fixed `character_spacing` effect on text width calculation

Extra spacing was applied to the end of string which resulted in visually
incorrect center/right alligned text.

(Matjaz Gregoric, [#1117](https://github.com/prawnpdf/prawn/pull/1117))


### Fixed instance variable `@italic_angle` not initialized

(Rostislav Svoboda, [#1095](https://github.com/prawnpdf/prawn/pull/1095))

### Correctly handle image pathnames

Prawn used to not close IOs passed to `image`. This prevented file deletion. The
case is handled correctly now.

(Guido Gloor Modjib, [#1090](https://github.com/prawnpdf/prawn/pull/1090))

### Stricter validation of text alignment mode

(Luciano Sousa, [#1057](https://github.com/prawnpdf/prawn/pull/1057))

### Fixed `Prawn::View#respond_to_missing?` method signature

When you use `Prawn::View` mixin to create custom class that extends Prawn's
functionality, the method `respond_to?` was giving an error when called with a
missing method.

(Vitor Arimitsu, [#1065](https://github.com/prawnpdf/prawn/pull/1065))

### Updated list of supported Rubies

* Added Ruby 2.6 support
* Added Ruby 2.7 support
* Added JRuby 9.2 support

* Dropped Ruby 2.2 & 2.3 support
* Dropped JRuby 9.1 support

Ruby 2.2 & 2.3 are not supported upstream any more.

(Alexander Mankuta)

### Fixed gradient cache key collision

Packing gradient attributes down to 8-bit values causes collisions when
generating the SHA1 digest.

(Paul Jackson, [#1049](https://github.com/prawnpdf/prawn/pull/1049))

### Unknown font message

Provide more detail in error message about unknown font.

(Dan Allen, [#1045](https://github.com/prawnpdf/prawn/pull/1045))

### Fixed double require

Remove superfluous pdf-core requires

(Matt Patterson, [#1032](https://github.com/prawnpdf/prawn/pull/1032)

## PrawnPDF 2.2.2

Relax pdf-inspector depspec.

(Alexander Mankuta)

## PrawnPDF 2.2.1

Fixed margins on individual pages.

(Eric Hankins, [#1003](https://github.com/prawnpdf/prawn/pull/1003))

## PrawnPDF 2.2.0

### Added support of TTC fonts

You can use TTC fonts with Prawn now.

(Jamis Buck, [#1002](https://github.com/prawnpdf/prawn/pull/1007))

### Join style is validated now

Previously it was possible to specify anything for join style which could result
in and invalid document. It's impossible now.

(Tim Woodbury, [#989](https://github.com/prawnpdf/prawn/pull/989))


### Fixed handling of NBSP in Windows-1252 text

NBSP was improperly treated as a regular space in Windows-1252 encoded text.


(Alexander Mankuta, [#939](https://github.com/prawnpdf/prawn/issues/939))

### Fixed wrong leading of one-line paragraphs

Extra leading was erroneously added to one-line paragraphs.

(Marcin Skirzynski, [#922](https://github.com/prawnpdf/prawn/pull/922))


### Fixed dashing

Dashing now allows 0 length segments. It now fully conforms to PDF spec.

(Thomas Leitner, [#1001](https://github.com/prawnpdf/prawn/issues/1001))


### Code of Conduct

PrawnPDF now has [Code of Conduct].

[Code of Conduct]: https://github.com/prawnpdf/prawn/blob/master/CODE_OF_CONDUCT.md


### Improved generated document consistency

There was a number of places in code that generated names for different
resources semi-randomly. That made hard to verify if document has any unexpected
changes. There was some effort to improve consistency.

(Alexander Mankuta)


### Improved gradients

Gradients can have multiple stops to blend more than two colors

Previously, only two colors could be specified in a gradient: the start and end
colors.  This change allows any number of colors to be specified, along with the
position between 0 and 1 as to where they should be displayed.

This change also comes with a change to the format of the `fill_gradient` and
`stroke_gradient` methods.  You can continue to use the old method parameters
and only specify two colors, or use the new keyword arguments to specify
arbitrary stops.

As a bonus, if you use the new method style, `apply_transformations` is set true
automatically.

(Roger Nesbitt, [#902](https://github.com/prawnpdf/prawn/issues/984))


### Supported Rubies has changed

* Removed MRI 2.0, JRuby 1.7, and Rubinius support
* Added MRI 2.4 and JRuby 9k


### Catch unexpected manual changes

For a long time changes to manual were hard to spot because it was a manual
process. There was no way to know for sure if the manual has changed or not.

Now manual changes are caught during build.

(Alexander Mankuta, [#949](https://github.com/prawnpdf/prawn/pull/949))


### Validate colors passed in as strings must be valid hexadecimal

Colors that were passed with a # would previously be misrepresented. Now
any colors passed in as a string must be valid hexadecimal or they will
raise an error.

(Tom Prats, [#807](https://github.com/prawnpdf/prawn/issues/807), [#869](https://github.com/prawnpdf/prawn/issues/869))

### Don't raise CannotFit when first fragment in array is a zero-width space

When determining what formatted text will fit within a box that has a fixed
width, don't raise a CannotFit error prematurely if the line begins with a
zero-width fragment and the next fragment exceeds the width.

Before finishing a line, the line is marked as not having more than one word
if the accumulated width of the line is zero. This is a clear indication that
the fragments previously visited did not produce any content (e.g., a
zero-width space).

(Dan Allen, [#984](https://github.com/prawnpdf/prawn/issues/984))


## PrawnPDF 2.1.0 -- 2016-02-29

### Added support for PNG images with indexed transparency

Prawn now properly hadles transparency in PNG images with indexed color.

(Maciej Mucha, [#783](https://github.com/prawnpdf/prawn/issues/783); Alexander Mankuta, [#920](https://github.com/prawnpdf/prawn/pull/920))

### Prawn no longer generates IRB warnings

Fix a few issues with code style that were triggering warnings in IRB when run in verbose mode (`irb -w`).

(Jesse Doyle, [#914](https://github.com/prawnpdf/prawn/pull/914))

### Gradients can have multiple stops to blend more than two colors

Previously, only two colors could be specified in a gradient: the start
and end colors.  This change allows any number of colors to be specified,
along with the position between 0 and 1 as to where they should be displayed.

This change also comes with a change to the format of the `fill_gradient`
and `stroke_gradient` methods.  You can continue to use the old method
parameters and only specify two colors, or use the new keyword arguments
to specify arbitrary stops.

As a bonus, if you use the new method style, `apply_transformations` is
set true automatically (see below).

(Roger Nesbitt)

### Gradients applied inside transformations are now correctly positioned

PDF gradients/patterns take coordinates in the coordinate space of the
document, not the "user space", so if you performed a scale/rotate/translate
and then painted a gradient inside, it wasn't correctly positioned.

This change tracks transformations applied to the document, and multiplies
the gradient matrix with this tracked transformation matrix so that the
gradient appears in the correct place in the document.

Because this changes how the x and y coordinates are interpreted, you must
manually add `apply_transformations: true` to your `stroke_gradient` and
`fill_gradient` calls to use the fixed behaviour in Prawn 2.  It is expected
that this will be the default in Prawn 3.

Please [refer to the wiki page on this change](https://github.com/prawnpdf/prawn/wiki/Gradient-Transformations)
for more information.

(Roger Nesbitt, [#891](https://github.com/prawnpdf/prawn/issues/891), [#894](https://github.com/prawnpdf/prawn/pull/894))

### Prawn::Graphics::BlendMode#blend_mode added
Blend modes can be used to change the way two layers are blended together. The
BM key is added to the External Graphics State based on the v1.4 PDF spec. `blend_mode`
accepts a single blend mode or array of blend modes. If an array is passed, the
PDF viewer blends layers based on the first valid blend mode.

## PrawnPDF 2.0.2 -- 2015-07-15

### Links in repeaters/stamps are now clickable

Previously, url links were not clickable when rendered within a stamp. The
proper annotation references are now added to the page object that the
stamp is called, thereby generating a clickable link in the pdf.

Because repeaters are built upon stamps, this fix should also solve
issues with links inside of repeaters.

(Jesse Doyle, [#801](https://github.com/prawnpdf/prawn/issues/801), [#498](https://github.com/prawnpdf/prawn/issues/498))

## PrawnPDF 2.0.1 -- 2015-03-23

### Fix regression in draw_text() with rotation

Due to missing tests, a typo snuck into the `draw_text()` method in PDF::Core,
preventing it from working properly when called with the `:rotate` option.

This issue has been resolved, and a test has been added to Prawn's test suite.
Speaking more generally, we need to improve the condition of the tests for
`PDF::Core`, and make a clear separation between Prawn's test suite and
PDF::Core's tests. Currently there are lots of little gaps that can lead
to this sort of problem.

[Robert S. Gerus, [pdf-core#15](https://github.com/prawnpdf/pdf-core/pull/15)]

## PrawnPDF 2.0.0 -- 2015-02-26

### Changes to supported Ruby versions

Now that Ruby 1.9.3 is no longer supported by the Ruby core team, Prawn will no
longer attempt to maintain 1.9.x compatibility.

We will continue to support Ruby 2.0.0 and 2.1.x, and have added support for Ruby
2.2.x as well.

If you're using JRuby, we recommend using JRuby 1.7.x (>= 1.7.18) in 2.0 mode
for now. Please file bug reports if you run into any problems!

### Changes to PrawnPDF's versioning policies

Starting with this release, we will set version numbers based on the following policy:

* Whenever a documented feature is modified in a backwards-incompatible way,
we'll bump our major version number.

* Whenever we add new functionality without breaking backwards compatibility,
we'll bump our minor version number.

* Whenever we cut maintenance releases (which cover only bug fixes,
documentation, and internal improvements), we'll bump our tiny version number.

This policy is similar in spirit to [Semantic Versioning](http://semver.org/),
and we may end up formally adopting SemVer in the future.

The main caveat is that if a feature is not documented (either in our API
documentation or in Prawn's manual), you cannot assume anything about its
intended behavior. Prawn has a lot of cruft left in it due to piecewise
development over nearly a decade, so the APIs have not been designed as
much as they have been organically grown.

To make sure that the amount of undefined behavior in Prawn shrinks over time,
we'll make sure to review and revise documentation whenever new functionality
is added, and also whenever we change existing features.

### All decimals in PDF output are now rounded to a fixed precision of 4 decimal places

This should improve compatibility across viewers that do not support
arbitrarily long decimal numbers, without effecting practical use
at all. (A PDF point is 1/72 inch, so 0.0001 PDF point is a very, very small number).

This patch was added in response to certain PDFs on certain versions of Adobe
Reader raising errors when viewed.

(Gregory Brown, [#782](https://github.com/prawnpdf/prawn/pull/782))

### Fixed text width calculation to prevent unnecessary soft hyphen

Previously, the `width_of` method would include the width of all soft hyphens
in a string, regardless of whether they would be rendered or not. This caused
lines of text to appear longer than they actually were, causing unnecessary
wrapping and hyphenation at times.

We've changed this calculation to only include the width of a soft hyphen when
it will actually be rendered (i.e. when a line needs to be wrapped), which
should prevent unnecessary hyphenation and text wrapping in strings containing
soft hyphens.

(Mario Albert, [#775](https://github.com/prawnpdf/prawn/issues/775), [#786](https://github.com/prawnpdf/prawn/pull/786))

### Fixed styled text width calculations when using TTF files

Previously, `width_of` calculations on styled text were relying on the
document font's name attribute in order to look up the appropriate
font style. This doesn't work for TTF fonts, since the name is a full
path to a single style of font, and the Prawn must know about the font
family in order to find another style.

The `width_of` method has been updated to use the font family instead,
allowing calculations to work properly with TTFs.

(Ernie Miller, [#827](https://github.com/prawnpdf/prawn/pull/827))

### Fixed broken vertical alignment for center and bottom

In earlier versions of Prawn, center alignment and bottom alignment in text
boxes worked in a way that is inconsistent with common typographical
conventions:

* Vertically centered text was padded so that the distance between the
top of the box and the ascender of the first line of text was made equal to the
distance between the descender of the bottom line to the descender of the last line of text.

* Bottom aligned text included the line gap specified by a font, leaving a bit of
extra in the box space below the descender of the last line of text.

Other commonly used software typically uses the baseline rather than the descender
when centering text, and does not include the line gap when bottom aligning text.
We've changed Prawn's behavior to be consistent with those conventions, which
should result in less surprising output.

That said, this problem has existed in Prawn for a very, very long time. Check your code to
see if you've been working around this issue, because if so it may cause breakage.

For a very detailed discussion (with pictures), see issue [#169](https://github.com/prawnpdf/prawn/issues/169).

(Jesse Doyle, [#788](https://github.com/prawnpdf/prawn/pull/788))

### Calling dash(0) now raises an error instead of generating a corrupt PDF

In earlier versions of Prawn, accidentally calling `dash(0)` instead of
`undash` in an attempt to clear dash settings would generate a corrupted
document instead of raising an error, making debugging difficult.

Because `dash(0)` is not a valid API call, we now raise an error that says
"Zero length dashes are invalid. Call #undash to disable dashes.", making
the source of the problem much clearer.

### Vastly improved handling of encodings for PDF built in (AFM) fonts

Prawn has always had comprehensive UTF-8 support for TTF font files, but many
users still rely on the "built in" AFM fonts that are provided by PDF viewers.
These fonts only support the very limited set of internationalized characters
specified by the Windows-1252 character encoding, and that has been a long
standing source of confusion and awkward behaviors.

Earlier versions of Prawn attempted to transcode UTF-8 to Windows-1252
automatically, but some of our low level features either assumed that
text was already encoded properly, or returned text in a different
encoding than what was provided because of the internal transcoding
operations. We also handled Windows-1252 encoding manually, so strings
would come back tagged as ASCII-8BIT instead of Windows-1252, making
things even more confusing.

In this release, we've made some major behavior changes to the way AFM
fonts work so that users need to think less about Prawn's internals:

* Text handling for all public Prawn methods is now UTF-8-in, UTF-8-out,
making Windows-1252 transcoding purely an implementation detail of Prawn
that isn't visible from the outside.

* When using AFM fonts + non-ASCII characters that are NOT supported in
Windows-1252, an exception will be raised rather than replacing w.
 `_`.

* When using AFM fonts + non-ASCII characters that are supported in
 Windows-1252, users will see a warning about the limited
internationalization support, along with a recommendation to use a TTF
 font instead.

* The warning includes instructions on how to disable it (just set
`Prawn::Font::AFM.hide_m17_warning = true`)

* When using AFM fonts + ASCII only text, no warning will be seen.

* Internally, we're now using Ruby's M17n system to handle the encoding
into Windows-1252, so text.encoding will come back as Windows-1252
when `AFM#normalize_encoding` is called, rather than `ASCII-8Bit`

None of the above issues apply when using TTF fonts with Prawn, because
those have always been UTF-8 in, UTF-8 out, and no transcoding was
done internally. It is still our recommendation for those using internationalized
text to use TTF fonts because they do not have the same limitations
as AFM fonts, but those who need to use AFM for whatever reason
should benefit greatly from these changes.

(Gregory Brown, [#793](https://github.com/prawnpdf/prawn/pull/793))

### Temporarily restored the Document#on_page_create method

This method was moved into PDF::Core in the Prawn 1.3.0 release, removing
it from the `Prawn::Document` API. Although it is a low-level method not
meant for general use, it is necessary for certain tasks that we do not
have proper support for elsewhere.

This method should still be considered part of Prawn's internals and is subject
to change at any time, but we have restored it temporarily until we have
a suitable replacement for it. See the discussion on [#797](https://github.com/prawnpdf/prawn/issues/797)
for more details.

(Jesse Doyle, [#797](https://github.com/prawnpdf/prawn/issues/797), [#825](https://github.com/prawnpdf/prawn/pull/825))

## PrawnPDF 1.3.0 -- 2014-09-28

### Added the Prawn::View mixin for using Prawn's DSL in your own classes.

In complex Prawn-based documents, it is a common pattern to create subclasses
of `Prawn::Document` to isolate different components from one another,
or to provide some customized rendering methods. However, the sprawling
nature of the `Prawn::Document` object makes this an unsafe practice:
it implements hundreds of methods and contains dozens of instance variables,
all of which can conflict with any subclass functionality.

`Prawn::View` provides a safer alternative by using object
composition instead of inheritance. This will keep your state and
methods separate from Prawn's internals, while still allowing you to
directly call any methods provided by the `Prawn::Document` object.

Here's an example of `Prawn::View` in use:

```ruby
class Greeter
  include Prawn::View

  def initialize(name)
    @name = name
  end

  def say_hello
    text "Hello, #{@name}!"
  end

  def say_goodbye
    font("Courier") do
      text "Goodbye, #{@name}!"
    end
  end
 end

greeter = Greeter.new("Gregory")

greeter.say_hello
greeter.say_goodbye

greeter.save_as("greetings.pdf")
```

Wherever possible, please convert your `Prawn::Document` subclasses to use
`Prawn::View` instead. It is much less invasive, and is nearly a drop-in
replacement for the existing common practice.

### Soft hyphenation no longer renders unnecessary hyphens in the last word of paragraphs.

A defect in our text rendering system was to blame for this bad behavior.
For more details, see [#347](https://github.com/prawnpdf/prawn/issues/347).

([#773](https://github.com/prawnpdf/prawn/pull/773), [#774](https://github.com/prawnpdf/prawn/pull/774) -- Mario Albert)

### Fonts with unsupported character mappings will now only fail if you use unsupported glyphs.

A bug in TTFunk prevented certain fonts from being used because they contained
unsupported character map information. In most cases, this information would
only be needed to render a handful of obscure glyphs, and so most users
would never run into issues by using them.

This issue has been resolved, and should help improve compatibility
for CJK-based fonts in particular.

([TTFunk #20](https://github.com/prawnpdf/ttfunk/pull/20) -- Dan Allen)

### Prawn no longer triggers Ruby warnings when loaded

Some minor issues in our TTFunk dependency was causing many warnings to be
generated upon loading Prawn. As of this release, you should now be able to
run Ruby with warnings on and see no warnings generated from Prawn
or its dependencies.

([TTFunk #21](https://github.com/prawnpdf/ttfunk/pull/21) -- Jesse Doyle)

## PrawnPDF 1.2.1 -- 2014-07-27

This release includes all changes from 1.2.0, which was yanked due to a packaging error.

### Prawn::Table has been moved into an optional gem extension.

In addition to adding `require "prawn/table"` to your code, you will need to install
the `prawn-table` gem to make use of table and cell rendering functionality in Prawn 1.2+.

The `prawn-table` gem will be maintained by Hartwig Brandl, and is semi-officially
supported by the Prawn maintenance team. That means that we'll continue to watch its
CI builds against each Prawn release, and help to resolve any compatibility
issues as soon as possible.

Please see the [prawn-table repository](https://github.com/prawnpdf/prawn-table)
for more information.

### Text box now has an option to disable wrapping by character.

This feature is useful for preventing mid-word breaks when used in combination with the
`:shrink_to_fit` overflow option. See the following example practical use case:

```ruby
# An example shared by Simon Mansfield
Prawn::Document.generate("x.pdf") do
  stroke_rectangle [0, bounds.top], 100, 50

  font('Helvetica', size: 50) do
    formatted_text_box(
      [{text: 'VEGETARIAN'}],
      at: [0, bounds.top],
      width: 100,
      height: 50,
      overflow: :shrink_to_fit,
      disable_wrap_by_char: true  # <---- newly added in 1.2
    )
  end
end
```

Without setting `:disable_wrap_by_char`, the code above will break the word "VEGETARIAN"
into two lines rather than shrinking it all the way down to fit on a single unbroken line.

To maintain backwards compatibility, `:disable_wrap_by_char` is implemented as
an optional behavior that is off by default.

([#752](https://github.com/prawnpdf/prawn/pull/752), James Coleman)

### Fallback fonts no longer break global font styling.

In earlier versions of Prawn, using the fallback font system caused styling information
(i.e. bold, italic) for all fonts to be lost, and the only workaround to this
problem was to specify style explicitly for each individual text fragment.

Now that this issue has been resolved, it is safe to use the `font` method to set
styles globally, even if fallback fonts are in use.

([#743](https://github.com/prawnpdf/prawn/pull/743), Pete Sharum)

### Formatted text box dry runs no longer modify graphics state

Dry runs are supposed to be a side-effect-free way of simulating text rendering,
but a bug in earlier versions of Prawn caused the graphics state to be modified
if colors were set on text fragments. This patch resolves that issue.

([#736](https://github.com/prawnpdf/prawn/pull/736), Christian Hieke)

### Fixed manual build failure on Ruby 1.9.3

When we extracted Prawn::ManualBuilder, we accidentally broke its support for
Ruby 1.9.3. That issue has been resolved, and a new version of the
`prawn-manual_builder` gem has been released.

## PrawnPDF 1.1.0 -- 2014-06-27

In addition to the notes below, please see the
[Prawn 1.1 blog post](http://elmcitycraftworks.org/post/90062338793/prawn-1-1-0-released").

### Table support now disabled by default, moving to its own gem soon.

We're planning to extract table generation into its own semi-officially
supported gem in a future release. Until then, you can use the following line
to enable table support in your projects:

```ruby
require "prawn/table"
```

As of right now tables are still supported as an experimental public feature --
we only disabled it by default to make sure people are aware that it will be
extracted into its own gem soon.

### I/O objects are now supported in the font system.

You can now pass a fully formed Prawn::Font object in addition to a
file path when adding a font family to your document. `Prawn::Font.load`
now also accepts IO object as an alternative to explicitly specifying
a path on the filesystem. For example:

```ruby
io = File.open "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
@pdf.font_families["DejaVu Sans"] = {
  normal: Prawn::Font.load(@pdf, io)
}

@pdf.font "DejaVu Sans"
@pdf.text "In DejaVu Sans"
```

([#730](https://github.com/prawnpdf/prawn/pull/730), Evan Sharp)

### We now use the Prawn::ManualBuilder gem to generate our documentation.

In previous releases, the system that generated Prawn's manual
was bundled directly with Prawn and not usable by third party extensions.
We've now extracted that system into
[its own project](https://github.com/prawnpdf/prawn-manual_builder) so that it can be
used by anyone who wants to ship PDF-based documentation for their Prawn code.

`Prawn::ManualBuilder` is still a bit rough around the edges because it
wasn't originally meant for general purpose use, but extracting out the
code is an important first step in making it more useful for everyone. Bug fixes
and improvements are welcome!

([#728](https://github.com/prawnpdf/prawn/pull/728), Gregory Brown)

### Table headers are now rendered only if there is also room for non-header rows.

Orphaned header rows look bad and could be considered a rendering bug,
and so this change fixes that problem by making sure there is enough room
for at least one row of non-header data before attempting to render headers.

([#717](https://github.com/prawnpdf/prawn/pull/717), Uwe Kubosch)

### Row-spans in multi-row headers are no longer lost after pagebreak

In previous versions of Prawn, multi-row headers with rowspan would render
incorrectly in multi-page tables. This bug has now been fixed.

([#721](https://github.com/prawnpdf/prawn/issues/721, "#723":https://github.com/prawnpdf/prawn/pull/723), Deron Meranda + Hartwig Brandl)

### Fixed a table bug when using an array of column widths

This is a fix for yet another edge case in cell width calculations. See tickets for details.

([#710](https://github.com/prawnpdf/prawn/issues/710), [#712](https://github.com/prawnpdf/prawn/pull/712) Hartwig Brandl)

## PrawnPDF 1.0.0 -- 2014-03-16

In addition to the notes below, please see the [Prawn 1.0 blog post.][1-0-blog-post]

[1-0-blog-post]: http://elmcitycraftworks.org/post/79929183748/prawn-1-0-is-finally-here

### Margins are now properly restored after a multi-page bounding box is rendered.

In a Prawn document, it's possible to reset the page margins on each
newly created page: i.e. `@doc.start_new_page(:margin => 64)`. But due to a
very old bug, this feature did not work correctly any time that a
bounding box spanned more than one page.

Because many of Prawn's features rely on bounding boxes internally, this problem
typically would reveal itself indirectly. This example from Malte Schmitz helped
us finally track down the problem:

```ruby
pdf = Prawn::Document.new(:margin => 200)
pdf.table [["Foo"]] * 20, position: :center # spans multiple pages
pdf.start_new_page(:margin => 0) # should have updated margins but didn't
pdf.text "Foo " * 100
```

The root cause of this problem has been found and fixed, and there should no longer be
unexpected issues when using the `:margin` parameter to `start_new_page`.

### Transaction support has been removed from Prawn, and the Document#group feature has been temporarily disabled.

We've discovered some very serious flaws in Prawn's transaction support which can
easily cause documents to become corrupted. The only thing transactions were used internally
for in Prawn was to support the `Document#group` feature, but the underlying defects were
severe enough to make `Document#group` unsafe for use whenever a page boundary is crossed.

We'd like to bring back both transactions and grouping functionality, but it's going to
involve some major work to do so cleanly. Until that happens, we've decided its better
not to provide the feature at all than it is to have folks try to use something that
will likely result in hard to hunt down bugs.

An experiment to restore grouping functionality without relying on transactions
has already been released by Daniel Dengler in the [prawn-grouping](https://github.com/ddengler/prawn-grouping)
extension, so you may want to give that a try if you need grouping functionality.

### Fixed broken git clone of Prawn repository for Windows

A useless file named `..` was accidentally checked into the repository,
which was causing failures with cloning Prawn on Windows. That file has been removed,
resolving the problem.

( [#692](https://github.com/prawnpdf/prawn/pull/692), Johnny Shields)

### Deprecated gradient method signatures have been removed.

The  `fill_gradient(point, width, height,...)` and `stroke_gradient(point, width, height,...)`
calls are no longer supported. Use `fill_gradient(from, to, ...)`  and `stroke_gradient(from, to, ...)` instead.

( [#674](https://github.com/prawnpdf/prawn/pull/674), Alexander Mankuta )

### PDF::Core::Outline has been moved back to Prawn::Outline

When we first broke out the PDF::Core namespace from Prawn's internals, our outline
support ended going along with it. That was accidental, and so we've now restored
Prawn::Outline and marked it as part of our stable API.

## Pre-1.0 Release Notes

For changes before our 1.0 release, see the following wiki page:
https://github.com/prawnpdf/prawn/wiki/CHANGELOG
