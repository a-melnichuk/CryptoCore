//
//  ptc_base58.h
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/5/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_BASE58_H
#define PTC_BASE58_H

#include <stdlib.h>
#include <stdint.h>

#include "ptc_result.h"

// Base58 decode

typedef struct ptc_base58_context {
    uint8_t* bytes;
    size_t length;
} ptc_base58_context;

ptc_result ptc_b58_decode(ptc_base58_context* c, const void* in_base58, size_t in_length);
void ptc_b58_decode_destroy(ptc_base58_context* c);

ptc_result ptc_b58check_decode(ptc_base58_context* c,
                               const char* in_str,
                               const uint8_t* in_version, size_t in_version_length);

// Base58 encode

ptc_result ptc_b58_encode(const void* in_bytes,
                          size_t in_length,
                          char* out_base58,
                          size_t* out_length);

ptc_result ptc_b58check_encode(const void* in_bytes,
                               size_t in_length,
                               const uint8_t* in_version, size_t in_version_length,
                               char* out_base58, size_t* out_length);

ptc_result ptc_b58check(const char* in_str, const uint8_t* in_version, size_t in_version_length);

#endif
