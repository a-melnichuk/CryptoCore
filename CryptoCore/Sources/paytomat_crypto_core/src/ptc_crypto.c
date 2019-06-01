//
//  ptc_crypto.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <keccak-tiny/keccak-tiny.h>
#include <blake2b/blake2b.h>
#include <openssl/sha.h>
#include <openssl/ripemd.h>
#include <openssl/hmac.h>

#include "ptc_crypto.h"

// Keccak

ptc_result ptc_keccak256(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    if (in_data == NULL || out_bytes == NULL)
        return PTC_ERROR_NULL_ARGUMENT;
    
    int result = keccak_256(out_bytes, 32, in_data, in_length);
    return result == 0 ? PTC_SUCCESS : PTC_ERROR_GENERAL;
}

ptc_result ptc_keccak512(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    if (in_data == NULL || out_bytes == NULL)
        return PTC_ERROR_NULL_ARGUMENT;
    
    int result = keccak_512(out_bytes, 64, in_data, in_length);
    return result == 0 ? PTC_SUCCESS : PTC_ERROR_GENERAL;
}

// Blake2b

ptc_result ptc_blake2b(const void* in_data, size_t in_length, uint8_t* out_bytes, size_t out_length)
{
    if (in_data == NULL || out_bytes == NULL)
        return PTC_ERROR_NULL_ARGUMENT;
    
    error_t result = blake2bCompute(NULL, 0, in_data, in_length, out_bytes, out_length);
    switch (result) {
        case NO_ERROR:
            return PTC_SUCCESS;
        case ERROR_OUT_OF_MEMORY:
            return PTC_ERROR_OUT_OF_MEMORY;
        case ERROR_INVALID_PARAMETER:
            return PTC_ERROR_INVALID_PARAM;
        default:
            return PTC_ERROR_GENERAL;
    }
}

ptc_result ptc_blake2b256(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    return ptc_blake2b(in_data, in_length, out_bytes, 32);
}

// SHA

ptc_result ptc_sha256(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    if (in_data == NULL || out_bytes == NULL)
        return PTC_ERROR_NULL_ARGUMENT;
    
    int result;
    SHA256_CTX c;
    
    if ((result = SHA256_Init(&c)) != 1)
        return PTC_ERROR_GENERAL;
    if ((result = SHA256_Update(&c, in_data, in_length)) != 1)
        return PTC_ERROR_GENERAL;
    if ((result = SHA256_Final(out_bytes, &c)) != 1)
        return PTC_ERROR_GENERAL;
    return PTC_SUCCESS;
}

ptc_result ptc_sha512(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    if (in_data == NULL || out_bytes == NULL)
        return PTC_ERROR_NULL_ARGUMENT;
    
    int result;
    SHA512_CTX c;
    if ((result = SHA512_Init(&c)) != 1)
        return PTC_ERROR_GENERAL;
    if ((result = SHA512_Update(&c, in_data, in_length)) != 1)
        return PTC_ERROR_GENERAL;
    if ((result = SHA512_Final(out_bytes, &c)) != 1)
        return PTC_ERROR_GENERAL;
    return PTC_SUCCESS;
}

ptc_result ptc_sha256_sha256(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    uint8_t bytes[32] = {0};
    ptc_result result;
    if ((result = ptc_sha256(in_data, in_length, bytes)) != PTC_SUCCESS)
        return result;
    return ptc_sha256(bytes, 32, out_bytes);
}

// RIPEMD

ptc_result ptc_ripemd160(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    if (in_data == NULL || out_bytes == NULL)
        return PTC_ERROR_NULL_ARGUMENT;
    
    int result;
    RIPEMD160_CTX c;
    if ((result = RIPEMD160_Init(&c)) != 1)
        return PTC_ERROR_GENERAL;
    if ((result = RIPEMD160_Update(&c, in_data, in_length)) != 1)
        return PTC_ERROR_GENERAL;
    if ((result = RIPEMD160_Final(out_bytes, &c)) != 1)
        return PTC_ERROR_GENERAL;
    return PTC_SUCCESS;
}

ptc_result ptc_sha256_ripemd160(const void* in_data, size_t in_length, uint8_t* out_bytes)
{
    uint8_t bytes[32] = {0};
    ptc_result result;
    if ((result = ptc_sha256(in_data, in_length, bytes)) != PTC_SUCCESS)
        return result;
    return ptc_ripemd160(bytes, 32, out_bytes);
}

// HMAC

ptc_result ptc_hmacsha512(const void* in_data,
                          size_t in_data_length,
                          const void* in_key,
                          size_t in_key_length,
                          uint8_t* out_bytes)
{
    uint32_t length = 64;
    HMAC(EVP_sha512(),
         in_key, in_key_length,
         in_data, in_data_length,
         out_bytes,
         &length);
    return PTC_SUCCESS;
}
