//
//  ptc_waves_crypto.c
//  WavesCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <paytomat_crypto_core/ptc_crypto.h>
#include "ptc_waves_crypto.h"

ptc_result ptc_waves_secure_hash(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    ptc_result result;
    uint8_t bytes[32];
    if ((result = ptc_blake2b256(in_data, in_length, bytes)) != PTC_SUCCESS)
        return result;
    return ptc_keccak256(bytes, 32, out_bytes);
}
