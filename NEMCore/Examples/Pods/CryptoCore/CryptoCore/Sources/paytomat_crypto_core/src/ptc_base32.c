//
//  ptc_base32.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <math.h>
#include <base32/base32.h>
#include "ptc_base32.h"

ptc_result ptc_b32_encode(const void* in_data, size_t in_length, uint8_t *out_bytes)
{
    size_t out_length = ptc_b32_encoded_length(in_length);
    int result = base32_encode(in_data, (int) in_length, out_bytes, (int) out_length);
    return result == -1 ? PTC_ERROR_GENERAL : PTC_SUCCESS;
}

ptc_result ptc_b32_decode(const void* in_data, size_t in_length, int8_t* out_bytes)
{
    int result = base32_decode(in_data, (uint8_t*) out_bytes, (int) in_length);
    return result == -1 ? PTC_ERROR_GENERAL : PTC_SUCCESS;
}

size_t ptc_b32_encoded_length(size_t in_length)
{
    return (in_length * 8 + 4) / 5;
}

size_t ptc_b32_decoded_length(size_t in_length)
{
    return ceil(in_length / 1.6);
}
