//
//  ptc_waves_transaction.c
//  WavesCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <paytomat_crypto_core/ptc_util.h>
#include <paytomat_crypto_core/ptc_base58.h>
#include <paytomat_crypto_core/ptc_crypto.h>
#include "ptc_waves_address.h"
#include "ptc_waves_transaction.h"

ptc_result ptc_waves_sign(const void* in_private_key,
                          const uint8_t* in_data,
                          size_t in_length,
                          uint8_t* out_signature) {
    ptc_result result = PTC_ERROR_GENERAL;
    uint8_t random_bytes[PTC_WAVES_SIGNATURE_RANDOM_BYTES];
    if ((result = ptc_random_bytes(random_bytes, PTC_WAVES_SIGNATURE_RANDOM_BYTES)) != PTC_SUCCESS)
        return result;
    return ptc_xed25519_sign(in_private_key,
                             in_data,
                             in_length,
                             random_bytes,
                             out_signature);
}
