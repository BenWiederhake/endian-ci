/* This file is part of endian-ci, a simple sanity check of portable-endian.h
 * Copyright 2016 Ben Wiederhake
 * License: MIT, see LICENSE
 *
 * This file tests *all* core functionality. */

#include "portable-endian/portable-endian.h"

#include <assert.h>
#include <stdint.h>
#include <stdio.h>

static unsigned int checks_run = 0;
static unsigned int checks_passed = 0;

#define check_equal(bits,modifier,actual,expected) \
    do { \
        int passed; \
        unsigned long actual_v; \
        unsigned long expected_v; \
        typedef char check_actual_fits[ \
            sizeof(actual) <= sizeof(unsigned long) ? 1 : 1]; \
        (void)(check_actual_fits*)(void*)0; /* "unused typedef" warning */ \
        ++checks_run; \
        actual_v = (unsigned long)(actual);  \
        expected_v = (unsigned long)(expected); \
        passed = actual_v == expected_v; \
        if (!passed) { \
            printf("#%d, %d bits: %s\n", \
                checks_run, \
                bits, \
                passed ? "PASS" : "FAIL"); \
            printf("\tExpression:   %s\n", #actual); \
            printf("\tActual:       %" modifier "lx\n", actual_v); \
            printf("\tExpected:     %s\n", #expected); \
            printf("\tExpected val: %" modifier "lx\n", expected_v); \
        } else { \
            ++checks_passed; \
        } \
    } while (0)

#define define_test(bits,test_val,hexits) \
static void test_##bits() { \
    typedef char check_uintXt_bit_count[ \
        bits == (sizeof(uint##bits##_t)*8) ? 1 : -1]; \
    union test_union { \
        uint##bits##_t as_uint; \
        unsigned char as_uchars[(bits)/8]; \
    }; \
    union test_union v; \
    union test_union v_as_le; \
    union test_union v_as_be; \
    int i; \
    typedef char check_hexit_and_bit_count[(bits)==(hexits*4) ? 1 : -1]; \
    (void)(check_uintXt_bit_count*)(void*)0; /* "unused typedef" warning */ \
    (void)(check_hexit_and_bit_count*)(void*)0; /* "unused typedef" warning */ \
    \
    v.as_uint = (uint##bits##_t)test_val; \
    v_as_le.as_uint = pe_htole##bits(v.as_uint); \
    v_as_be.as_uint = pe_htobe##bits(v.as_uint); \
    /* Are little and big endian actually correct? */ \
    for (i = 0; i < ((bits)/8); ++i) { \
        check_equal(bits,"02",v_as_le.as_uchars[i],(bits)/8 - i); \
        check_equal(bits,"02",v_as_be.as_uchars[i],       1 + i); \
    } \
    /* Is the roundtrip nilpotent? */ \
    check_equal(bits,"0" #hexits,pe_le##bits##toh(v_as_le.as_uint),v.as_uint); \
    check_equal(bits,"0" #hexits,pe_be##bits##toh(v_as_be.as_uint),v.as_uint); \
}

define_test(16,0x0102UL,4)
/* 4 + 2 tests */

define_test(32,0x01020304UL,8)
/* 8 + 2 tests */

#ifndef PORTABLE_ENDIAN_NO_UINT_64_T
/* All other uints are guaranteed to exist for this test. */
define_test(64,0x0102030405060708UL,16)
/* 16 + 2 tests */
#endif

int main() {
    printf("Begin functionality testing\n");
    test_16();
    test_32();
#ifndef PORTABLE_ENDIAN_NO_UINT_64_T
    test_64();
#endif
    printf("End functionality testing: Ran %d checks (%d successful)\n",
           checks_run, checks_passed);
    if (checks_passed != checks_run) {
        printf("=> FAIL, as there are failed checks.\n");
        return 1;
    }
    if (checks_run != 34 && checks_run != 16) {
        printf("=> FAIL, weird amount of checks run.\n");
        return 2;
    }
    printf("=> PASS\n");
    return 0;
}
