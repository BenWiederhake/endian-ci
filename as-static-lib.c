/* This file is part of endian-ci, a simple sanity check of portable-endian.h
 * Copyright 2016 Ben Wiederhake
 * License: MIT, see LICENSE
 *
 * This file allows us to view portable-endian.h as a standalone compilation
 * unit.  One would expect that the following two invocations are equivalent:
 *     gcc $FLAGS -c -o foo.o portable-endian/portable-endian.h
 *     gcc $FLAGS -c -o foo.o as-static-lib.c
 * However, in the former case gcc produces a "precompiled header",
 * even with '-c', which is nonsense and can't be used as library. */

#include "portable-endian/portable-endian.h"
