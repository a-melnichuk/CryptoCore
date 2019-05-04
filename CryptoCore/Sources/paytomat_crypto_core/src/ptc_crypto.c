//
//  ptc_crypto.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include "ptc_crypto.h"

// Keccak

ptc_result ptc_keccak256(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    int result = keccak_256(out_bytes, 32, in_data, in_length);
    return result == 0 ? PTC_RESULT_SUCCESS : PTC_RESULT_ERROR_GENERAL;
}

ptc_result ptc_keccak512(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    int result = keccak_512(out_bytes, 64, in_data, in_length);
    return result == 0 ? PTC_RESULT_SUCCESS : PTC_RESULT_ERROR_GENERAL;
}

// Blake2b

ptc_result ptc_blake2b(const void* in_data, size_t in_length, uint8_t* out_bytes, size_t out_length)
{
    error_t result = blake2bCompute(NULL, 0, in_data, in_length, out_bytes, out_length);
    switch (result) {
        case NO_ERROR:
            return PTC_RESULT_SUCCESS;
        case ERROR_OUT_OF_MEMORY:
            return PTC_RESULT_ERROR_OUT_OF_MEMORY;
        case ERROR_INVALID_PARAMETER:
            return PTC_RESULT_ERROR_INVALID_PARAM;
        default:
            return PTC_RESULT_ERROR_GENERAL;
    }
}

ptc_result ptc_blake2b256(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    return ptc_blake2b(in_data, in_length, out_bytes, 32);
}

