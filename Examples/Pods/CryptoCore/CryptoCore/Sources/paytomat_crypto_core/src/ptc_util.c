//
//  ptc_util.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include "ptc_util.h"

uint16_t ptc_swap_uint16(uint16_t val)
{
    return (val << 8) | (val >> 8 );
}

int16_t ptc_swap_int16(int16_t val)
{
    return (val << 8) | ((val >> 8) & 0xFF);
}

uint32_t ptc_swap_uint32(uint32_t val)
{
    val = ((val << 8) & 0xFF00FF00) | ((val >> 8) & 0xFF00FF);
    return (val << 16) | (val >> 16);
}

int32_t ptc_swap_int32(int32_t val)
{
    val = ((val << 8) & 0xFF00FF00) | ((val >> 8) & 0xFF00FF);
    return (val << 16) | ((val >> 16) & 0xFFFF);
}

int64_t ptc_swap_int64(int64_t val)
{
    val = ((val << 8) & 0xFF00FF00FF00FF00ULL) | ((val >> 8) & 0x00FF00FF00FF00FFULL);
    val = ((val << 16) & 0xFFFF0000FFFF0000ULL) | ((val >> 16) & 0x0000FFFF0000FFFFULL);
    return (val << 32) | ((val >> 32) & 0xFFFFFFFFULL);
}

uint64_t ptc_swap_uint64(uint64_t val)
{
    val = ((val << 8) & 0xFF00FF00FF00FF00ULL) | ((val >> 8) & 0x00FF00FF00FF00FFULL);
    val = ((val << 16) & 0xFFFF0000FFFF0000ULL) | ((val >> 16) & 0x0000FFFF0000FFFFULL);
    return (val << 32) | (val >> 32);
}

int64_t ptc_current_time_in_millis(void)
{
    if (__builtin_available(iOS 10.0, *)) {
        long            ms; // Milliseconds
        time_t          s;  // Seconds
        struct timespec spec;
        clock_gettime(CLOCK_REALTIME, &spec);
        s  = spec.tv_sec;
        ms = round(spec.tv_nsec / 1.0e6); // Convert nanoseconds to milliseconds
        if (ms > 999) {
            s++;
            ms = 0;
        }
        return s * 1000 + ms;
    } else {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        return (((int64_t) tv.tv_sec) * 1000) + (tv.tv_usec / 1000);
    }
}

bool ptc_is_little_endian()
{
    int i = 1;
    return (int)*((unsigned char *)&i)==1;
}

static const int8_t ptc_hexmap[] = {
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, //  !"#$%&'
    -1, -1, -1, -1, -1, -1, -1, -1, // ()*+,-./
    0,  1,  2,  3,  4,  5,  6,  7, // 01234567
    8,  9, -1, -1, -1, -1, -1, -1, // 89:;<=>?
    -1, 10, 11, 12, 13, 14, 15, -1, // @ABCDEFG
    -1, -1, -1, -1, -1, -1, -1, -1, // HIJKLMNO
    -1, -1, -1, -1, -1, -1, -1, -1, // PQRSTUVW
    -1, -1, -1, -1, -1, -1, -1, -1, // XYZ[\]^_
    -1, 10, 11, 12, 13, 14, 15, -1, // `abcdefg
    -1, -1, -1, -1, -1, -1, -1, -1, // hijklmno
    -1, -1, -1, -1, -1, -1, -1, -1, // pqrstuvw
    -1, -1, -1, -1, -1, -1, -1, -1, // xyz{|}~.
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1, // ........
    -1, -1, -1, -1, -1, -1, -1, -1  // ........
};


void ptc_reverse(void* in_bytes, size_t in_length)
{
    uint8_t *lo = in_bytes;
    uint8_t *hi = in_bytes + in_length - 1;
    uint8_t swap;
    while (lo < hi) {
        swap = *lo;
        *lo++ = *hi;
        *hi-- = swap;
    }
}

void ptc_reverse_uint64(void* in_bytes, size_t in_length)
{
    if (in_length == 0)
        return;
    uint64_t* bytes = in_bytes;
    uint64_t *lo = bytes;
    uint64_t *hi = bytes + in_length / sizeof(uint64_t) - 1;
    uint64_t swap;
    while (lo < hi) {
        swap = ptc_swap_uint64(*lo);
        *lo++ = ptc_swap_uint64(*hi);
        *hi-- = swap;
    }
}

void ptc_to_hex(const uint8_t* in_string, size_t in_length, char* out_hex_string)
{
    const char* hex = "0123456789abcdef";
    for (int i = 0; i < in_length; ++i) {
        out_hex_string[i * 2] = hex[(in_string[i] >> 4) & 0xF];
        out_hex_string[i * 2 + 1] = hex[in_string[i] & 0xF];
    }
    out_hex_string[in_length * 2] = '\0';
}


bool ptc_from_hex(const char* in_hex_string, size_t in_length, uint8_t* out_bytes)
{
    if (in_length & 1) // string is not a multiple of two
        return false;
    size_t n = in_length / 2;
    for (int i = 0; i < n; ++i) {
        char c1 = in_hex_string[2 * i];
        char c2 = in_hex_string[2 * i + 1];
        if (!isascii(c1) || !isascii(c2))
            return false;
        char a = ptc_hexmap[c1];
        char b = ptc_hexmap[c2];
        if (a < 0 || b < 0)
            return false;
        out_bytes[i] = ((a & 0xF) << 4) | (b & 0xF);
    }
    return true;
}

void ptc_print_hex(const char* tag, const void* in_bytes, size_t in_length)
{
    printf("%s", tag);
    const uint8_t* buf = in_bytes;
    for (int i = 0; i < in_length; ++i)
        printf("%02x", buf[i]);
    printf("\n");
}
