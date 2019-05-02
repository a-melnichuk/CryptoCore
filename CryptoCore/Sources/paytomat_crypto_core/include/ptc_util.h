//
//  ptc_util.h
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_UTIL_H
#define PTC_UTIL_H

#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <ctype.h>
#include <math.h>
#include <time.h>

uint16_t ptc_swap_uint16(uint16_t val);
int16_t ptc_swap_int16(int16_t val);
uint32_t ptc_swap_uint32(uint32_t val);
int32_t ptc_swap_int32(int32_t val);
int64_t ptc_swap_int64(int64_t val);
uint64_t ptc_swap_uint64(uint64_t val);

void ptc_reverse(void* in_bytes, size_t in_length);
void ptc_reverse_uint64(void* in_bytes, size_t in_length);

int64_t ptc_current_time_in_millis(void);

bool ptc_is_little_endian(void);

void ptc_to_hex(const uint8_t* in_string, size_t in_length, char* out_hex_string);
bool ptc_from_hex(const char* in_hex_string, size_t in_length, uint8_t* out_bytes);
void ptc_print_hex(const char* tag, const void* in_bytes, size_t in_length);



#endif
