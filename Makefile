# This file is part of endian-ci, a simple sanity check of portable-endian.h
# Copyright 2016 Ben Wiederhake
# License: MIT, see LICENSE

# FIXME: Test all features, not only core functionality
#        for the most common use case (duh).
# FIXME: Come up with a better way to test and document the full matrix.

GCC         ?= gcc
GCC_OPTS    := -Wall -Wextra -Werror -pedantic -O2 -g
CLANG       ?= clang
CLANG_OPTS  := -Weverything -Werror -pedantic -O2 -g

all: check-clang check-gcc

.PHONY: check-clang
check-clang: test-functionality.c
	@command -v "${CLANG}" > /dev/null || \
	{  echo "clang not found, tried: ${CLANG}" && \
	   echo "    override with 'CLANG=<your-clang>')" && \
	   exit 1; }
#--
	@rm -f bin/test-functionality
	${CLANG} -std=c89 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${CLANG_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
#	C89 does not define the keyword "inline".  So for C89,
#	one can't test without P_E_FORCE_INLINE re-defined properly.
#--
	@rm -f bin/test-functionality
	${CLANG} -std=gnu89 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${CLANG_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
#	Funny enough, gnu89 *does* include the 'inline' keyword,
#	but clang doesn't accept it anyway.
#--
	@rm -f bin/test-functionality
	${CLANG} -std=c99 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${CLANG_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${CLANG} -std=c99 ${CLANG_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${CLANG} -std=gnu99 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${CLANG_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${CLANG} -std=gnu99 ${CLANG_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${CLANG} -std=c11 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${CLANG_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality
#--
	@rm -f bin/test-functionality
	${CLANG} -std=c11 ${CLANG_OPTS} \
	    -o bin/test-functionality test-functionality.c
	./bin/test-functionality

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
	@echo ${GCC} -std=gnu89 ${GCC_OPTS} \
	    -o bin/test-functionality test-functionality.c
	@if ${GCC} --version | grep -qc '^Apple.*clang' ; \
	then \
		echo "=> SKIPPED, gcc on mac is actually clang which behaves ... weirdly." ; \
	else \
		${GCC} -std=gnu89 ${GCC_OPTS} \
			-o bin/test-functionality test-functionality.c; \
		./bin/test-functionality; \
	fi \
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
	@echo ${GCC} -std=c11 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${GCC_OPTS} \
		-o bin/test-functionality test-functionality.c
	@if ${GCC} -std=c11 --target-help >/dev/null 2>/dev/null; \
	then \
		${GCC} -std=c11 -DPORTABLE_ENDIAN_FORCE_INLINE="static" ${GCC_OPTS} \
			-o bin/test-functionality test-functionality.c; \
		./bin/test-functionality; \
	else \
		echo "=> SKIPPED, C11 not supported"; \
	fi
#--
	@rm -f bin/test-functionality
	@echo ${GCC} -std=c11 ${GCC_OPTS} \
		-o bin/test-functionality test-functionality.c
	@if ${GCC} -std=c11 --target-help >/dev/null 2>/dev/null; \
	then \
	    ${GCC} -std=c11 ${GCC_OPTS} \
	        -o bin/test-functionality test-functionality.c; \
		./bin/test-functionality; \
	else \
		echo "=> SKIPPED, C11 not supported"; \
	fi
