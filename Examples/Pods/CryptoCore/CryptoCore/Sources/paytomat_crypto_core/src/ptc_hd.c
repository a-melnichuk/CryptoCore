//
//  ptc_hd.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/24/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <openssl/sha.h>
#include <openssl/hmac.h>
#include <openssl/ec.h>
#include <string.h>
#include "ptc_util.h"
#include "ptc_crypto.h"
#include "ptc_hd.h"

void ptc_hd_key_init(ptc_hd_key* hd_key)
{
    if (hd_key == NULL)
        return;
    hd_key->private_key.data = NULL;
    hd_key->private_key.length = 0;
    hd_key->public_key.data = NULL;
    hd_key->public_key.length = 0;
    memset(hd_key->chain_code, 0, sizeof(hd_key->chain_code));
    hd_key->depth = 0;
    hd_key->fingerprint = 0;
    hd_key->child_index = 0;
}

bool ptc_hd_key_create(ptc_hd_key* hd_key,
                       const uint8_t* private_key,
                       size_t private_key_length,
                       const uint8_t* public_key,
                       size_t public_key_length,
                       const uint8_t* chain_code,
                       uint8_t depth,
                       uint32_t fingerprint,
                       uint32_t child_index)
{
    if (hd_key == NULL)
        return false;
    ptc_hd_key_init(hd_key);
    if (!ptc_buffer_create_copy(&hd_key->private_key, private_key, private_key_length))
        goto cleanup;
    if (!ptc_buffer_create_copy(&hd_key->public_key, public_key, public_key_length))
        goto cleanup;
    memcpy(hd_key->chain_code, chain_code, sizeof(hd_key->chain_code));
    hd_key->depth = depth;
    hd_key->fingerprint = fingerprint;
    hd_key->child_index = child_index;
    return true;
cleanup:
    ptc_hd_key_destroy(hd_key);
    return false;
}

void ptc_hd_key_destroy(ptc_hd_key* hd_key)
{
    if (hd_key == NULL)
        return;
    ptc_buffer_destroy(&hd_key->private_key);
    ptc_buffer_destroy(&hd_key->public_key);
    hd_key->depth = 0;
    hd_key->fingerprint = 0;
    hd_key->child_index = 0;
}

ptc_result ptc_hd_key_derive(const ptc_hd_key* src_hd_key,
                             uint32_t index,
                             bool hardened,
                             ptc_hd_key* dst_hd_key)
{
    if (!src_hd_key || !dst_hd_key)
        return PTC_ERROR_NULL_ARGUMENT;
    
    uint32_t child_index = OSSwapHostToBigInt32(hardened ? (0x80000000 | index) : index);
    uint8_t* data = NULL;
    size_t data_length = 0;
    if (hardened) {
        // hardened = [padding][private_key][child_index]
        uint8_t padding = 0;
        data_length = sizeof(padding) + src_hd_key->private_key.length + sizeof(child_index);
        if ((data = malloc(data_length)) == NULL)
            return PTC_ERROR_OUT_OF_MEMORY;
        uint8_t* d = data;
        memcpy(d, &padding, sizeof(padding));
        d += sizeof(padding);
        if (src_hd_key->private_key.data != NULL) {
            memcpy(d, src_hd_key->private_key.data, src_hd_key->private_key.length);
            d += src_hd_key->private_key.length;
        }
        memcpy(d, &child_index, sizeof(child_index));
    } else {
         // not hardened = [public_key][child_index]
        data_length = src_hd_key->public_key.length + sizeof(child_index);
        if ((data = malloc(data_length)) == NULL)
            return PTC_ERROR_OUT_OF_MEMORY;
        uint8_t* d = data;
        memcpy(d, src_hd_key->public_key.data, src_hd_key->public_key.length);
        d += src_hd_key->public_key.length;
        memcpy(d, &child_index, sizeof(child_index));
    }
    
    ptc_result result = PTC_ERROR_GENERAL;
    uint8_t* result_bytes = NULL;
    size_t result_bytes_length = 0;
    uint8_t digest[64];
    if ((result = ptc_hmacsha512(data,
                                 data_length,
                                 src_hd_key->chain_code,
                                 sizeof(src_hd_key->chain_code),
                                 digest)) != PTC_SUCCESS) {
        free(data);
        return result;
    }
    uint8_t* derived_private_key = digest;
    uint8_t* derived_chain_code = digest + 32;
    
    BN_CTX* ctx = BN_CTX_new();
    BIGNUM* curve_order = BN_new();
    BIGNUM* factor = BN_new();
    BN_hex2bn(&curve_order, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141");
    BN_bin2bn(derived_private_key, 32, factor);
    // Factor is too big, this derivation is invalid.
    if (BN_cmp(factor, curve_order) >= 0) {
        result = PTC_ERROR_GENERAL;
        goto cleanup;
    }
    if (src_hd_key->private_key.data != NULL) {
        BIGNUM *private_key = BN_new();
        BN_bin2bn(src_hd_key->private_key.data, src_hd_key->private_key.length, private_key);
        BN_mod_add(private_key, private_key, factor, curve_order, ctx);
        // Check for invalid derivation.
        if (BN_is_zero(private_key)) {
            result = PTC_ERROR_GENERAL;
            goto cleanup_private_key;
        }
        result_bytes_length = BN_num_bytes(private_key);
        if ((result_bytes = malloc(result_bytes_length)) == NULL) {
            result = PTC_ERROR_OUT_OF_MEMORY;
            goto cleanup_private_key;
        }
        BN_bn2bin(private_key, result_bytes);
    cleanup_private_key:
        BN_free(private_key);
        if (result != PTC_SUCCESS)
            goto cleanup;
    } else {
        BIGNUM *public_key = BN_new();
        BN_bin2bn(src_hd_key->public_key.data, src_hd_key->public_key.length, public_key);
        EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
        EC_POINT *point = EC_POINT_new(group);
        EC_POINT_bn2point(group, public_key, point, ctx);
        EC_POINT_mul(group, point, factor, point, BN_value_one(), ctx);
        BIGNUM *n = BN_new();
        // Check for invalid derivation.
        if (EC_POINT_is_at_infinity(group, point) == 1) {
            result = PTC_ERROR_GENERAL;
            goto cleanup_public_key;
        }
        result_bytes_length = 33;
        if ((result_bytes = malloc(result_bytes_length)) == NULL) {
            result = PTC_ERROR_OUT_OF_MEMORY;
            goto cleanup_public_key;
        }
        EC_POINT_point2bn(group, point, POINT_CONVERSION_COMPRESSED, n, ctx);
        BN_bn2bin(n, result_bytes);
    cleanup_public_key:
        BN_free(n);
        BN_free(public_key);
        EC_POINT_free(point);
        EC_GROUP_free(group);
        if (result != PTC_SUCCESS)
            goto cleanup;
    }
    
    uint8_t fingerprint[20];
    if ((result = ptc_sha256_ripemd160(src_hd_key->public_key.data,
                                       src_hd_key->public_key.length,
                                       fingerprint)) != PTC_SUCCESS)
        goto cleanup;

    if (!ptc_hd_key_create(dst_hd_key,
                           result_bytes,
                           result_bytes_length,
                           result_bytes,
                           result_bytes_length,
                           derived_chain_code,
                           src_hd_key->depth + 1,
                           *((uint32_t*) fingerprint),
                           child_index)) {
        result = PTC_ERROR_OUT_OF_MEMORY;
        goto cleanup;
    }
    result = PTC_SUCCESS;
cleanup:
    if (result_bytes != NULL)
        memset(result_bytes, 0, result_bytes_length);
    free(result_bytes);
    BN_free(factor);
    BN_free(curve_order);
    BN_CTX_free(ctx);
    if (data != NULL)
        memset(data, 0, data_length);
    free(data);
    return result;
}
