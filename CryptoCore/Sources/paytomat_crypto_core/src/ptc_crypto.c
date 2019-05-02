//
//  ptc_crypto.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include "ptc_crypto.h"

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

