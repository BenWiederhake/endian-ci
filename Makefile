# This file is part of endian-ci, a simple sanity check of portable-endian.h
# Copyright 2016 Ben Wiederhake
# License: MIT, see LICENSE

# FIXME: Test all features, not only core functionality
#        for the most common use case (duh).
# FIXME: Come up with a better way to test and document the full matrix.

GCC         ?= gcc
GCC_OPTS    := -Wall -Wextra -Werror -pedantic -O2 -g

all: check-gcc

.PHONY: check-gcc
check-gcc: test-functionality.c
	@command -v "${GCC}" > /dev/null || \
	{  echo "gcc not found, tried: ${GCC}" && \
	   echo "    override with 'GCC=<your-gcc>')" && \
	   exit 1; }
#--
	@rm -f bin/test-functionality
	${GCC} -std=c89 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
#	C89 does not define the keyword "inline".  So for C89,
#	one can't test without P_E_FORCE_INLINE re-defined properly.
#--
	@rm -f bin/test-functionality
	${GCC} -std=gnu89 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
#	Funny enough, gnu89 *does* include the 'inline' keyword.
	@rm -f bin/test-functionality
	${GCC} -std=gnu89 ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${GCC} -std=c99 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${GCC} -std=c99 ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${GCC} -std=gnu99 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${GCC} -std=gnu99 ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${GCC} -std=c11 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${GCC} -std=c11 ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
