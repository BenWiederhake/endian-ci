<!-- This file is part of endian-ci, a simple sanity check of portable-endian.h
     Copyright 2016 Ben Wiederhake
     License: MIT, see LICENSE -->
# Simple sanity check of portable-endian.h

This projects aims to test and document when, how and where
[portable-endian.h](https://github.com/BenWiederhake/portable-endian)
works.

## Portability / requirements

Just like portable-endian itself, this battery of tests strives to be
extremely portable -- and succeeds, as far as I can tell.  Currently,
the `Makefile` requires POSIX make and probably POSIX shell (only as
part of `Makefile`).  Only if you need to change the Makefile (which is
automatically generated from `autogen.py`, you also need Python on
*any* system (not necessarily the system under test). Language major
version 2, of course.

For the full table of compatibility, see `compatibility.tsv`

Here are all rules to determine what works and what doesn't:
- Using an old version of gcc that doesn't support `-std=c11`?  Then C11
  doesn't work (duh).
- Using a standard that doesn't support the `inline` keyword?  Then
  setting `PORTABLE_ENDIAN_MODIFIERS` shouldn't contain the "keyword"
  `inline` (duh).
- Using `-std=gnu89` and the `inline` keyword?  Then `clang` doesn't work.
  Please note that Mac OS claims to have "gcc", but that's just a symbolic
  link to clang, so in this case, "gcc" doesn't work, either.
- That's all, as far as I can tell.


## Dimensions

This project checks along the following dimenstions:
- OS:
    * Debian (used for development)
    * [Ubuntu 12.04, Ubuntu 14.04, Mac OS X](https://travis-ci.org/BenWiederhake/endian-ci)
    * [FreeBSD](https://gitlab.com/BenWiederhake/endian-ci/builds)
- Compiler: gcc, clang
- C standard ("language"): C89, gnu89, C99, gnu99, C11
- Integer support: all, without `uint64_t`
- Use case ("mode"):
    * default: used as header-only without any special flags
    * inline: used as header-only with additional hints to inline all functions
    * defhere: current compilation unit is "special" and *defines* all
      functions.
    * defext: used as external library (counter-part to
      defhere)
- Then, all functions of the library are checked to actually do their job.
  Furthermore, nilpotence is checked.  In other words, it must always hold
  that `x==betoh(htobe(x))` and `x==letoh(htole(x))`.

This is a typical example of combinatorial explosion.  However, the
execution time should be reasonable enough.

## Cross-platform testing

With the current split into the targets `build-all` and
`run-all` (the latter just executes all binaries in `bin/`), it should
be well possible to cross-compile during `build-all`, copy the
executable to the target platform, and run them there.  Note that you
should not try to link them together, as that would either fail or (at least)
render all linkage tests moot.

## Compilers

I'd love to see Pull Requests to test this specifically with XCode and
MSVC.  Until then, it'll be gcc- and clang-only.

## Python script

Let me say sorry upfront.

However, I just found no way to pack *all* the logic for combinatorial
explosion, exception detection (e.g. "build C11 only if C11 is
supported") in a neatly readable, portable Makefile.  Thus, I opted for
an automatically generated Makefile.
