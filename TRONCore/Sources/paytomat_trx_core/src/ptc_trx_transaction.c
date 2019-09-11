//
//  ptc_trx_transaction.c
//  TRONCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include "ptc_trx.h"
#include <stdio.h>
#include <secp256k1/secp256k1.h>
#include <secp256k1/secp256k1_recovery.h>

ptc_result ptc_trx_sign_transaction(const uint8_t* in_data, size_t in_length,
                                    const uint8_t* in_privkey, size_t in_privkey_length,
                                    uint8_t* out_signature)
{
    if (!in_data || !in_privkey || !out_signature)
    return PTC_ERROR_NULL_ARGUMENT;
    ptc_result result = PTC_ERROR_GENERAL;
    
    uint8_t data[32];
    if ((result = ptc_sha256(in_data, in_length, data)) != PTC_SUCCESS)
    return result;
    secp256k1_context* c = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY);
    secp256k1_ecdsa_recoverable_signature rec_sig;
    if (secp256k1_ecdsa_sign_recoverable_canonical(c, &rec_sig, data, in_privkey, NULL, NULL, false) != 1) {
        result = PTC_ERROR_INVALID_SIGNATURE;
        goto cleanup;
    }
    
    memcpy(out_signature, rec_sig.data, PTC_TRX_SIGNATURE_BYTE_COUNT);
    ptc_reverse_uint64(out_signature, 32);
    ptc_reverse_uint64(out_signature + 32, 32);
    result = PTC_SUCCESS;
cleanup:
    secp256k1_context_destroy(c);
    return result;
}
