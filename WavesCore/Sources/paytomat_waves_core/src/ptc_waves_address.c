//
//  ptc_waves_address.c
//  WavesCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <paytomat_crypto_core/ptc_crypto.h>
#include <paytomat_crypto_core/ptc_base58.h>
#include "ptc_waves_address.h"
#include "ptc_waves_crypto.h"

ptc_result ptc_waves_public_key(const void* in_privkey, uint8_t* out_pubkey)
{
    uint8_t basepoint[PTC_WAVES_BASEPOINT_BYTE_COUNT] = {9};
    return ptc_curve25519_donna(in_privkey, basepoint, out_pubkey);
}

ptc_result ptc_waves_address(const void* in_pubkey, uint8_t in_scheme, uint8_t* out_address_bytes)
{
    ptc_result result;
    uint8_t pubkey_secure_hash[PTC_WAVES_SECURE_HASH_BYTE_COUNT];
    if ((result = ptc_waves_secure_hash(in_pubkey, PTC_WAVES_PUBKEY_BYTE_COUNT, pubkey_secure_hash)) != PTC_SUCCESS)
        return result;
    out_address_bytes[0] = 1;
    out_address_bytes[1] = in_scheme;
    memcpy(out_address_bytes + 2, pubkey_secure_hash, 20);
    uint8_t checksum_secure_hash[PTC_WAVES_SECURE_HASH_BYTE_COUNT];
    if ((result = ptc_waves_secure_hash(out_address_bytes, 22, checksum_secure_hash)) != PTC_SUCCESS)
        return result;
    memcpy(out_address_bytes + 22, checksum_secure_hash, 4);
    return PTC_SUCCESS;
}

ptc_result ptc_waves_address_valid(const char* in_address, uint8_t in_scheme)
{
    if (in_address == NULL)
        return PTC_ERROR_NULL_ARGUMENT;
    size_t address_length = strlen(in_address);
    ptc_base58_context c;
    ptc_result result;

    if ((result = ptc_b58_decode(&c, in_address, address_length)) != PTC_SUCCESS)
        goto cleanup;
    if (c.length < PTC_WAVES_ADDRESS_BYTE_COUNT) {
        result = PTC_ERROR_INVALID_SIZE;
        goto cleanup;
    }
    
    if (c.bytes[0] != 1 || c.bytes[1] != in_scheme) {
        result = PTC_ERROR_INVALID_INPUTS;
        goto cleanup;
    }
    uint8_t secure_hash_bytes[PTC_WAVES_SECURE_HASH_BYTE_COUNT];
    if ((result = ptc_waves_secure_hash(c.bytes, 22, secure_hash_bytes)) != PTC_SUCCESS)
        goto cleanup;
    int cmp = memcmp(secure_hash_bytes, c.bytes + (c.length - PTC_WAVES_ADDRESS_CHECKSUM_BYTE_COUNT), PTC_WAVES_ADDRESS_CHECKSUM_BYTE_COUNT);
    result = cmp == 0 ? PTC_SUCCESS : PTC_ERROR_INVALID_CHECKSUM;
cleanup:
    ptc_b58_decode_destroy(&c);
    return result;
}
