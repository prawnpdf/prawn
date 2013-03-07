---
title: Documentation | Prawn
layout: default
---

The recommended way to read Prawn's documentation is to view it locally on your 
own machine. You can do this by cloning our git repositories, by unpacking your 
gems, or by running a gem server.  Online documentation can be out of date, or 
may be written against a version that you are not actually running on your 
machine. Local documentation is much less likely to lead you astray.

## Recommended Approach
 
RubyGems includes with it a server for hosting gems, which also can host up
documentation.  To use it, just run:

    gem server

Point your browser at http://localhost:8808 and you'll find an index of all 
installed gems, including Prawn. If this doesn't work or you prefer not to 
run a gem server, follow the manual instructions below.

## Manual building for Prawn:

To get the source, you can clone the 
[prawnpdf/prawn](http://github.com/prawnpdf/prawn)
repository from Github, or you can unpack the Prawn gem:

    gem unpack prawn
