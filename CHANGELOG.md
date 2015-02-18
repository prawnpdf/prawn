
## PrawnPDF 1.3.0 -- September 28, 2014

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

## PrawnPDF 1.2.1 -- July 27, 2014

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
`:shink_to_fit` overflow option. See the following example practical use case:

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

## PrawnPDF 1.1.0 -- June 27, 2014

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

## PrawnPDF 1.0.0 -- March 16, 2014

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

