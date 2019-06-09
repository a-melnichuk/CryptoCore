//
//  ptc_waves_transaction.c
//  NEMCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <curve25519/ed25519/ge.h>
#include <curve25519/ed25519/sc.h>
#include <paytomat_crypto_core/ptc_util.h>
#include <paytomat_crypto_core/ptc_base58.h>
#include <paytomat_crypto_core/ptc_crypto.h>
#include "ptc_nem_address.h"
#include "ptc_nem_transaction.h"

ptc_result ptc_nem_sign(const void* in_private_key,
                        const uint8_t* in_data,
                        size_t in_length,
                        uint8_t* out_signature)
{
    if (!in_data || !in_private_key || !out_signature)
        return PTC_ERROR_NULL_ARGUMENT;
    if (in_length == 0)
        return PTC_ERROR_INVALID_SIZE;
    
    ptc_result result = PTC_ERROR_OUT_OF_MEMORY;
    uint8_t* data = NULL;
    ge_p3 R;
    uint8_t r[64];
    uint8_t hram[64];
    uint8_t private_key_hash[64];
    uint8_t private_key_bytes[PTC_NEM_PRIVKEY_PART_BYTE_COUNT];
    uint8_t public_key[PTC_NEM_PUBKEY_BYTE_COUNT];
    
    if ((result = ptc_nem_public_key(in_private_key, public_key)) != PTC_SUCCESS)
        goto cleanup;
    
    memcpy(private_key_bytes, in_private_key, PTC_NEM_PRIVKEY_PART_BYTE_COUNT);
    ptc_reverse_uint64(private_key_bytes, PTC_NEM_PRIVKEY_PART_BYTE_COUNT);
    
    if ((result = ptc_sha3_512(private_key_bytes,
                               PTC_NEM_PRIVKEY_PART_BYTE_COUNT,
                               private_key_hash)) != PTC_SUCCESS)
        goto cleanup;
    
    if(!(data = malloc(in_length + PTC_NEM_PRIVKEY_PART_BYTE_COUNT)))
        goto cleanup;
    
    memcpy(data, private_key_hash + PTC_NEM_PRIVKEY_PART_BYTE_COUNT, PTC_NEM_PRIVKEY_PART_BYTE_COUNT);
    memcpy(data + PTC_NEM_PRIVKEY_PART_BYTE_COUNT, in_data, in_length);
    
    if ((result = ptc_sha3_512(data, in_length + PTC_NEM_PRIVKEY_PART_BYTE_COUNT, r)) != PTC_SUCCESS)
        goto cleanup;
    
    sc_reduce(r);
    ge_scalarmult_base(&R, r);
    ge_p3_tobytes(out_signature, &R);
    
    size_t data_length = in_length + PTC_NEM_SIGNATURE_PART_BYTE_COUNT + PTC_NEM_PUBKEY_BYTE_COUNT;
    free(data);
    if (!(data = malloc(data_length)))
        goto cleanup;
    
    memcpy(data, out_signature, PTC_NEM_SIGNATURE_PART_BYTE_COUNT);
    memcpy(data + PTC_NEM_SIGNATURE_PART_BYTE_COUNT, public_key, PTC_NEM_PUBKEY_BYTE_COUNT);
    memcpy(data + PTC_NEM_SIGNATURE_PART_BYTE_COUNT + PTC_NEM_PUBKEY_BYTE_COUNT, in_data, in_length);
    
    if ((result = ptc_sha3_512(data, data_length, hram)) != PTC_SUCCESS)
        goto cleanup;
    
    uint8_t private_key_right_part[PTC_NEM_PRIVKEY_PART_BYTE_COUNT];
    memcpy(private_key_right_part, private_key_hash, PTC_NEM_PRIVKEY_PART_BYTE_COUNT);
    
    private_key_right_part[0] &= 248;
    private_key_right_part[31] &= 127;
    private_key_right_part[31] |= 64;
    
    sc_reduce(hram);
    sc_muladd(out_signature + PTC_NEM_SIGNATURE_PART_BYTE_COUNT, hram, private_key_right_part, r);
    result = PTC_SUCCESS;
cleanup:
    memset(r, 0, sizeof r);
    memset(hram, 0, sizeof hram);
    memset(private_key_hash, 0, sizeof private_key_hash);
    memset(private_key_bytes, 0, sizeof private_key_bytes);
    free(data);
    return result;
}
