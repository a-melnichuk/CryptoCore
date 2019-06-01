//
//  ptc_base58.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/5/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <openssl/sha.h>
#include <base58/base58.h>
#include <string.h>

#include "ptc_base58.h"

static inline ptc_result ptc_base58_result(int base58_result)
{
    if (base58_result >= 0) // no error has occurred
        return PTC_SUCCESS;
    switch (base58_result) {
        case -1:
            return PTC_ERROR_SHA256_FAILED;
        case -2:
            return PTC_ERROR_SHA256_FAILED;
        case -3:
            return PTC_ERROR_INVALID_INPUTS;
        case -4:
            return PTC_ERROR_INVALID_SIZE;
        default:
            return PTC_ERROR_GENERAL;
    }
}

// Base58 decode

ptc_result ptc_b58_decode(ptc_base58_context* c, const void* in_base58, size_t in_length)
{
    if (!c)
        return PTC_ERROR_NULL_ARGUMENT;
    c->bytes = NULL;
    c->length = 0;
    
    size_t initital_length = in_length * 733 / 1000 + 1; // log_256(58) = log(58) / log(256), rounded up.
    size_t length = initital_length;
    uint8_t* bytes = calloc(length, sizeof(uint8_t));
    if (bytes == NULL)
        return PTC_ERROR_OUT_OF_MEMORY;
    
    ptc_result result = PTC_ERROR_GENERAL;
    if (!b58tobin(bytes, &length, in_base58, in_length))
        goto cleanup;
    
    if (length > initital_length) {
        // add first zero entries to array
        if ((c->bytes = malloc(length)) == NULL) {
            result = PTC_ERROR_OUT_OF_MEMORY;
            goto cleanup;
        }
        c->length = length;
        size_t added = length - initital_length;
        memset(c->bytes, 0, added);
        memcpy(c->bytes + added, bytes, initital_length);
    } else if (length < initital_length) {
        // strip array of first zero entries
        if ((c->bytes = malloc(length)) == NULL) {
            result = PTC_ERROR_OUT_OF_MEMORY;
            goto cleanup;
        }
        c->length = length;
        size_t removed = initital_length - length;
        memcpy(c->bytes, bytes + removed, length);
    } else {
        if ((c->bytes = malloc(length)) == NULL) {
            result = PTC_ERROR_OUT_OF_MEMORY;
            goto cleanup;
        }
        c->length = length;
        memcpy(c->bytes, bytes, length);
    }
    result = PTC_SUCCESS;
cleanup:
    memset(bytes, 0, length);
    free(bytes);
    return result;
}

ptc_result ptc_b58check_decode(ptc_base58_context* c,
                               const char* in_str,
                               const uint8_t* in_version, size_t in_version_length) {
    if (!c || !in_version || !in_str)
        return PTC_ERROR_NULL_ARGUMENT;
    if (in_version_length == 0)
        return PTC_ERROR_INVALID_PARAM;
    size_t str_len;
    if ((str_len = strlen(in_str)) == 0)
        return PTC_ERROR_INVALID_SIZE;
    
    ptc_result result = PTC_ERROR_GENERAL;
    if ((result = ptc_b58_decode(c, in_str, str_len)) != PTC_SUCCESS)
        goto cleanup;
    if (c->bytes == NULL) {
        result = PTC_ERROR_GENERAL;
        goto cleanup;
    }
    if (c->length == 0) {
        result = PTC_ERROR_INVALID_SIZE;
        goto cleanup;
    }
    if (memcmp(c->bytes, in_version, in_version_length) != 0) {
        result = PTC_ERROR_INVALID_PUBKEYHASH;
        goto cleanup;
    }
    int check_result = b58check(c->bytes, c->length, in_str, str_len);
    result = ptc_base58_result(check_result);
cleanup:
    return result;
}

void ptc_b58_decode_destroy(ptc_base58_context* c)
{
    if (!c)
        return;
    free(c->bytes);
    c->bytes = NULL;
    c->length = 0;
}

// Base58 encode

ptc_result ptc_b58_encode(const void* in_bytes, size_t in_length,
                          char* out_base58, size_t* out_length)
{
    bool success = b58enc(out_base58, out_length, in_bytes, in_length);
    return success ? PTC_SUCCESS : PTC_ERROR_GENERAL;
}

ptc_result ptc_b58check_encode(const void* in_bytes, size_t in_length,
                               const uint8_t* in_version, size_t in_version_length,
                               char* out_base58, size_t* out_length)
{
    bool success = b58check_enc_wide(out_base58, out_length,
                                     in_version, in_version_length,
                                     in_bytes, in_length);
    return success ? PTC_SUCCESS : PTC_ERROR_GENERAL;
}

ptc_result ptc_b58check(const char* in_str, const uint8_t* in_version, size_t in_version_length)
{
    if (!in_version || !in_str)
        return PTC_ERROR_NULL_ARGUMENT;
    if (in_version_length == 0)
        return PTC_ERROR_INVALID_PARAM;
    size_t str_len;
    if ((str_len = strlen(in_str)) == 0)
        return PTC_ERROR_INVALID_SIZE;
    
    ptc_result result;
    ptc_base58_context c;
    if ((result = ptc_b58_decode(&c, in_str, str_len)) != PTC_SUCCESS)
        goto cleanup;
    if (c.length == 0) {
        result = PTC_ERROR_INVALID_SIZE;
        goto cleanup;
    }
    if (memcmp(c.bytes, in_version, in_version_length) != 0) {
        result = PTC_ERROR_INVALID_PUBKEYHASH;
        goto cleanup;
    }
    int check_result = b58check(c.bytes, c.length, in_str, str_len);
    result = ptc_base58_result(check_result);
cleanup:
    ptc_b58_decode_destroy(&c);
    return result;
}

// Legacy

ptc_result ptc_base58_encode(const void* in_bytes,
                             size_t in_length,
                             uint8_t* out_base58,
                             size_t* out_length)
{
    bool success = b58enc((char*) out_base58, out_length, in_bytes, in_length);
    return success ? PTC_SUCCESS : PTC_ERROR_GENERAL;
}

ptc_result ptc_base58_check_encode(const void* in_bytes,
                                   size_t in_length,
                                   uint8_t in_version,
                                   char* out_base58,
                                   size_t* out_length)
{
    bool success = b58check_enc(out_base58, out_length, in_version, in_bytes, in_length);
    return success ? PTC_SUCCESS : PTC_ERROR_GENERAL;
}

ptc_result ptc_base58_decode_init(const void* in_base58,
                                  size_t in_length,
                                  uint8_t** out_bytes,
                                  size_t* out_length)
{
    size_t initital_length = in_length * 733 / 1000 + 1; // log_256(58) = log(58) / log(256), rounded up.
    size_t length = initital_length;
    uint8_t* bytes = calloc(length, sizeof(uint8_t));
    if (bytes == NULL)
        return PTC_ERROR_OUT_OF_MEMORY;
    ptc_result result = PTC_ERROR_GENERAL;
    if (!b58tobin(bytes, &length, in_base58, in_length))
        goto cleanup;
    
    if (length > initital_length) {
        // add first zero entries to array
        if ((*out_bytes = malloc(length)) == NULL) {
            result = PTC_ERROR_OUT_OF_MEMORY;
            goto cleanup;
        }
        *out_length = length;
        size_t added = length - initital_length;
        memset(*out_bytes, 0, added);
        memcpy(*out_bytes + added, bytes, initital_length);
    } else if (length < initital_length) {
        // strip array of first zero entries
        if ((*out_bytes = malloc(length)) == NULL) {
            result = PTC_ERROR_OUT_OF_MEMORY;
            goto cleanup;
        }
        *out_length = length;
        size_t removed = initital_length - length;
        memcpy(*out_bytes, bytes + removed, length);
    } else {
        memcpy(*out_bytes, bytes, length);
        *out_length = length;
    }
    result = PTC_SUCCESS;
cleanup:
    free(bytes);
    return result;
}

void ptc_base58_decode_destroy(uint8_t** in_decoded_array)
{
    if (!in_decoded_array)
        return;
    free(*in_decoded_array);
    *in_decoded_array = NULL;
}

ptc_result ptc_base58_check_decode(const char* in_str,
                                   uint8_t in_version,
                                   uint8_t** out_bytes,
                                   size_t* out_length)
{
    ptc_result result;
    size_t str_len;
    if (in_str == NULL)
        return PTC_ERROR_NULL_ARGUMENT;
    if ((str_len = strlen(in_str)) == 0)
        return PTC_ERROR_INVALID_SIZE;
    if ((result = ptc_base58_decode_init(in_str, str_len, out_bytes, out_length)) != PTC_SUCCESS)
        goto cleanup;
    size_t bin_len = *out_length;
    uint8_t* bin = *out_bytes;
    if (bin_len == 0) {
        result = PTC_ERROR_INVALID_SIZE;
        goto cleanup;
    }
    if (bin[0] != in_version) {
        result = PTC_ERROR_INVALID_PUBKEYHASH;
        goto cleanup;
    }
    int check_result = b58check(bin, bin_len, in_str, str_len);
    result = ptc_base58_result(check_result);
cleanup:
    return result;
}

ptc_result ptc_base58_check(const char* in_str, uint8_t in_pubkeyhash /* nullable */)
{
    ptc_result result;
    size_t str_len;
    uint8_t* bin = NULL;
    size_t bin_len;
    if (in_str == NULL)
        return PTC_ERROR_NULL_ARGUMENT;
    if ((str_len = strlen(in_str)) == 0)
        return PTC_ERROR_INVALID_SIZE;
    if ((result = ptc_base58_decode_init(in_str, str_len, &bin, &bin_len)) != PTC_SUCCESS)
        goto cleanup;
    if (bin_len == 0) {
        result = PTC_ERROR_INVALID_SIZE;
        goto cleanup;
    }
    if (bin[0] != in_pubkeyhash) {
        result = PTC_ERROR_INVALID_PUBKEYHASH;
        goto cleanup;
    }
    int check_result = b58check(bin, bin_len, in_str, str_len);
    result = ptc_base58_result(check_result);
cleanup:
    ptc_base58_decode_destroy(&bin);
    return result;
}
