# This file is part of endian-ci, a simple sanity check of portable-endian.h
# Copyright 2016 Ben Wiederhake
# License: MIT, see LICENSE

# ---------------------
# Feel free to override these

GCC         ?= gcc
CLANG       ?= clang

# ---------------------
# Constructing all combinations.
# I'd like to avoid the GNU extension $(forall ...)

# <C>ompilers
COMBOS_C        := clang gcc
DIAL_C_clang    := ${CLANG} -Weverything -Werror -pedantic -O2 -g
DIAL_C_gcc      := ${GCC} -Wall -Wextra -Werror -pedantic -O2 -g
# <L>anguages / specifications
# TODO: Different compilers support different specifications
# TODO: Linebreaks don't work.  Why?
COMBOS_CL       := ${COMBOS_C:%=%-c89} ${COMBOS_C:%=%-gnu89} ${COMBOS_C:%=%-c99} ${COMBOS_C:%=%-gnu99} ${COMBOS_C:%=%-c11}
DIAL_L_c89      := -std=c89
DIAL_L_gnu89    := -std=gnu89
DIAL_L_c99      := -std=c99
DIAL_L_gnu99    := -std=gnu99
DIAL_L_c11      := -std=c11
# <I>nteger support
COMBOS_CLI      := ${COMBOS_CL:%=%-allint} ${COMBOS_CL:%=%-noint64}
DIAL_I_allint   :=
DIAL_I_noint64  := -DPORTABLE_ENDIAN_NO_UINT_64_T
# Linkage <m>ode
COMBOS_CLIM     := ${COMBOS_CLI:%=%-noflags} ${COMBOS_CLI:%=%-inline} ${COMBOS_CLI:%=%-declhere} ${COMBOS_CLI:%=%-declext}
DIAL_M_noflags  :=
DIAL_M_inline   := -DPORTABLE_ENDIAN_FORCE_INLINE="static inline"
DIAL_M_declhere := -DPORTABLE_ENDIAN_FORCE_INLINE=
DIAL_M_declext  := -DPORTABLE_ENDIAN_FORCE_INLINE= \
                   -DPORTABLE_ENDIAN_DECLS_ONLY

ALL_BINS        := ${COMBOS_CLIM:%=bin/%}
ALL_OBJS        := ${COMBOS_CLIM:%=obj/%.o} ${COMBOS_CLI:%=obj/pe_%.o}

# FIXME: should be run-all
all: build-all

# ---------------------
# Here be dragons.
# This is the main matrix-comprehension

RAWNAME=$(notdir $@)
OBJNAME=obj/${RAWNAME}.o
PART_C=$(shell echo ${RAWNAME} | cut -d- -f1)
PART_L=$(shell echo ${RAWNAME} | cut -d- -f2)
PART_I=$(shell echo ${RAWNAME} | cut -d- -f3)
PART_M=$(shell echo ${RAWNAME} | cut -d- -f4)

# TODO: Not *all* binaries depend on 'as-static-lib.c'
# However, that file shouldn't change anyway, it's literally just an #include.

# Currently, it seems that the '%' is the only GNU-specific extension we use.
# FIXME: Try to be compatible to BSD make?

# This is a big shell script (but can't use "set -e").
# Does putting it in a separate file endanger portability?
# TODO: Try to extract this to a separate file.
${ALL_BINS}: bin/%: test-functionality.c as-static-lib.c \
					portable-endian/portable-endian.h
	echo "Building C=${PART_C}, L=${PART_L}, I=${PART_I}, M=${PART_M} ..." && \
	EXPECT="SUCCESS" && \
	if [ "x$$EXPECT" = "xSUCCESS" -a "gcc" = "${PART_C}" -a "c11" = "${PART_L}" ] ; \
	then \
		if ${GCC} -std=c11 --target-help >/dev/null 2>/dev/null ; \
		then : ; \
		else \
			EXPECT="FAIL: Old versions of gcc don't support C11" ; \
		fi ; \
	fi && \
	if [ "x$$EXPECT" = "xSUCCESS" -a "c89" = "${PART_L}" \
	     -a "inline" = "${PART_M}" ] ; \
	then \
		EXPECT="FAIL: Can't use 'inline' in C89" ; \
	fi && \
	if [ "x$$EXPECT" = "xSUCCESS" -a "gnu89" = "${PART_L}" \
	     -a "inline" = "${PART_M}" -a "clang" = "${PART_C}" ] ; \
	then \
		if ${GCC} --version | grep -qc '^Apple.*clang' ; \
			EXPECT="FAIL: Clang thinks 'inline' isn't part of gnu89" ; \
		fi ; \
	fi && \
	echo "Expecting $$EXPECT"

# ---------------------
# Boring and obvious infrastructure

.PHONY: build-all
build-all: ${ALL_BINS}

.PHONY: run-all
run-all: ${ALL_BINS}
	@for i in ${ALL_BINS}; \
	do \
		if test -x $$i ; \
		then \
			echo "Running test $$i:" ; \
			bin/$$i ; \
		else \
			echo "WARNING: skipping $$i: didn't build" ; \
		fi \
	done

.PHONY: clean
clean:
# Too verbose to print all 140 file names
	@echo 'rm -f $${ALL_BINS} $${ALL_OBJS}'
	@rm -f ${ALL_BINS} ${ALL_OBJS}
