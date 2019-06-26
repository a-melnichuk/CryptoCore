//
//  ptc_key.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/25/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <string.h>
#include <openssl/sha.h>
#include <openssl/hmac.h>
#include <openssl/ec.h>
#include "ptc_key.h"

ptc_result ptc_create_public_key(const uint8_t* private_key,
                                 int32_t private_key_length,
                                 bool compressed,
                                 ptc_buffer* public_key)
{
    if (!private_key || !public_key)
        return PTC_ERROR_NULL_ARGUMENT;
    ptc_result result = PTC_ERROR_GENERAL;
    BN_CTX *ctx = BN_CTX_new();
    EC_KEY *key = EC_KEY_new_by_curve_name(NID_secp256k1);
    const EC_GROUP *group = EC_KEY_get0_group(key);
    BIGNUM *prv = BN_new();
    BN_bin2bn(private_key, private_key_length, prv);
    
    EC_POINT *pub = EC_POINT_new(group);
    
    if (EC_POINT_mul(group, pub, prv, NULL, NULL, ctx) != 1)
        goto cleanup;
    if (EC_KEY_set_private_key(key, prv) != 1)
        goto cleanup;
    if (EC_KEY_set_public_key(key, pub) != 1)
        goto cleanup;
    
    if (compressed) {
        EC_KEY_set_conv_form(key, POINT_CONVERSION_COMPRESSED);
        int length = i2o_ECPublicKey(key, &public_key->data);
        public_key->length = length;
        result = PTC_SUCCESS;
    } else {
        if (!ptc_buffer_create(public_key, 65)) {
            result = PTC_ERROR_OUT_OF_MEMORY;
            goto cleanup;
        }
        BIGNUM *n = BN_new();
        EC_POINT_point2bn(group, pub, POINT_CONVERSION_UNCOMPRESSED, n, ctx);
        BN_bn2bin(n, public_key->data);
        BN_free(n);
        result = PTC_SUCCESS;
    }
cleanup:
    EC_POINT_free(pub);
    BN_free(prv);
    EC_KEY_free(key);
    BN_CTX_free(ctx);
    return result;
}

ptc_result ptc_derive_key(const uint8_t* password,
                          int32_t password_length,
                          const uint8_t* salt,
                          int32_t salt_length,
                          int32_t iterations,
                          int32_t key_length,
                          uint8_t* out_key)
{
    int result = PKCS5_PBKDF2_HMAC((const char*)password,
                                   password_length,
                                   salt,
                                   salt_length,
                                   iterations,
                                   EVP_sha512(),
                                   key_length,
                                   out_key);
    return result == 1 ? PTC_SUCCESS : PTC_ERROR_GENERAL;
}
