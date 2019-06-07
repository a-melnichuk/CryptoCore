//
//  ptc_waves_address.c
//  NEMCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curve25519/ed25519/ge.h>
#include <paytomat_crypto_core/ptc_crypto.h>
#include <paytomat_crypto_core/ptc_util.h>
//#include <paytomat_crypto_core/ptc_base32.h>
#include "ptc_nem_address.h"

ptc_result ptc_nem_public_key(const void* in_privkey, uint8_t* out_pubkey)
{
    if (!in_privkey || !out_pubkey)
        return PTC_ERROR_NULL_ARGUMENT;
    
    uint8_t privkey_cpy[PTC_NEM_PRIVKEY_PART_BYTE_COUNT];
    memcpy(privkey_cpy, in_privkey, PTC_NEM_PRIVKEY_PART_BYTE_COUNT);
    ptc_reverse_uint64(privkey_cpy, PTC_NEM_PRIVKEY_PART_BYTE_COUNT);
    
    ptc_result result;
    uint8_t privkey[PTC_NEM_PRIVKEY_BYTE_COUNT];
    if ((result = ptc_sha3_512(privkey_cpy, PTC_NEM_PRIVKEY_PART_BYTE_COUNT, privkey)) != PTC_SUCCESS)
        return result;
    
    privkey[0] &= 248;
    privkey[31] &= 127;
    privkey[31] |= 64;
    
    ge_p3 A;
    ge_scalarmult_base(&A, privkey);
    ge_p3_tobytes(out_pubkey, &A);
    
    return PTC_SUCCESS;
}

ptc_result ptc_nem_address(const void* in_pubkey, uint8_t in_scheme, int8_t* out_address_bytes)
{
    if (!in_pubkey || !out_address_bytes)
        return PTC_ERROR_NULL_ARGUMENT;
    
    ptc_result result = PTC_SUCCESS;
    uint8_t step_one_sha256[32];
    if ((result = ptc_sha3_256(in_pubkey, PTC_NEM_PUBKEY_BYTE_COUNT, step_one_sha256)) != PTC_SUCCESS)
        return result;
    
    uint8_t decoded_address[PTC_NEM_ADDRESS_DECODED_BYTE_COUNT]; // 1 version byte + 20 ripemd160 bytes + 4 checksum bytes
    decoded_address[0] = in_scheme;
    
    if ((result = ptc_ripemd160(step_one_sha256, 32, decoded_address + 1)) != PTC_SUCCESS)
        return result;
    
    uint8_t checksum_sha256[32];
    ptc_sha3_256(decoded_address, 21, checksum_sha256);
    memcpy(decoded_address + 21, checksum_sha256, PTC_NEM_ADDRESS_CHECKSUM_BYTE_COUNT);
    
    if ((result = ptc_b32_encode(decoded_address, PTC_NEM_ADDRESS_DECODED_BYTE_COUNT, out_address_bytes)) != PTC_SUCCESS)
        return result;
    return PTC_SUCCESS;
}

bool ptc_nem_address_valid(const char* in_address, uint8_t in_scheme)
{
    if (!in_address)
        return false;
    size_t in_address_length = strlen(in_address);
    if (in_address_length < PTC_NEM_ADDRESS_ENCODED_CHAR_COUNT)
        return false;
    bool valid = false;
    char* address = NULL;
    size_t trimmed_length = 0;
    ptc_nem_address_denormalize(in_address, in_address_length, &trimmed_length, NULL);
    if (trimmed_length == 0 || !(address = malloc(trimmed_length) ))
        return false;
    ptc_nem_address_denormalize(in_address, in_address_length, &trimmed_length, address);
    if (trimmed_length != PTC_NEM_ADDRESS_ENCODED_CHAR_COUNT)
        goto cleanup;
    uint8_t decoded_address[PTC_NEM_ADDRESS_DECODED_BYTE_COUNT];
    if (ptc_b32_decode(address, PTC_NEM_ADDRESS_ENCODED_CHAR_COUNT, decoded_address) != PTC_SUCCESS)
        goto cleanup;
    if (decoded_address[0] != in_scheme)
        goto cleanup;
    uint8_t checksum[32];
    if (ptc_sha3_256(decoded_address, 21, checksum) != PTC_SUCCESS)
        goto cleanup;
    valid = memcmp(checksum, decoded_address + 21, 4) == 0;
cleanup:
    free(address);
    return valid;
}

void ptc_nem_address_normalize(const char* in_address, size_t in_address_length, char* out_normalized_address)
{
    size_t in_offset = 0;
    size_t out_offset = 0;
    size_t n = in_address_length / 6;
    
    for (size_t i = 0; i < n; ++i, out_offset += 7, in_offset += 6) {
        memcpy(out_normalized_address + out_offset, in_address + in_offset, 6);
        out_normalized_address[out_offset + 6] = '-';
    }
    size_t tail = in_address_length - in_offset;
    if (tail > 0)
        memcpy(out_normalized_address + out_offset, in_address + in_offset, tail);
}

void ptc_nem_address_denormalize(const char* in_address,
                                 size_t in_address_length,
                                 size_t* out_normalized_address_length,
                                 char* out_normalized_address)
{
    if (*out_normalized_address_length == 0) {
        size_t count = 0;
        for (int i = 0; i < in_address_length; ++i) {
            if (in_address[i] == '-')
                ++count;
        }
        *out_normalized_address_length = in_address_length - count;
    } else {
        char c;
        for (size_t i = 0, j = 0; i < in_address_length; ++i) {
            c = in_address[i];
            if (c != '-')
                out_normalized_address[j++] = c;
        }
    }
}
