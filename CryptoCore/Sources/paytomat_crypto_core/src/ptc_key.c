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
#include <secp256k1/secp256k1.h>
#include "ptc_key.h"

ptc_result ptc_create_public_key(const uint8_t* private_key,
                                 int32_t private_key_length,
                                 bool compressed,
                                 uint8_t* public_key)
{
    if (!private_key || !public_key)
        return PTC_ERROR_NULL_ARGUMENT;
    ptc_result result = PTC_ERROR_GENERAL;
    secp256k1_context *c = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
    if (secp256k1_ec_seckey_verify(c, private_key) != 1) {
        result = PTC_ERROR_INVALID_PRIVATE_KEY;
        goto cleanup;
    }
    secp256k1_pubkey pubkey;
    if (secp256k1_ec_pubkey_create(c, &pubkey, private_key) != 1) {
        result = PTC_ERROR_PUBKEY_CREATION_FAILED;
        goto cleanup;
    }
    size_t len;
    unsigned int flags;
    if (compressed) {
        len = PTC_PUBLIC_KEY_COMPRESSED;
        flags = SECP256K1_EC_COMPRESSED;
    } else {
        len = PTC_PUBLIC_KEY_UNCOMPRESSED;
        flags = SECP256K1_EC_UNCOMPRESSED;
    }
    if (secp256k1_ec_pubkey_serialize(c, public_key, &len, &pubkey, flags) != 1) {
        result = PTC_ERROR_PUBKEY_SERIALIZATION_FAILED;
        goto cleanup;
    }
    result = PTC_SUCCESS;
cleanup:
    secp256k1_context_destroy(c);
    return result;
    
//    BN_CTX *ctx = BN_CTX_new();
//    EC_KEY *key = EC_KEY_new_by_curve_name(NID_secp256k1);
//    const EC_GROUP *group = EC_KEY_get0_group(key);
//    BIGNUM *prv = BN_new();
//    BN_bin2bn(private_key, private_key_length, prv);
//
//    EC_POINT *pub = EC_POINT_new(group);
//
//    if (EC_POINT_mul(group, pub, prv, NULL, NULL, ctx) != 1)
//        goto cleanup;
//    if (EC_KEY_set_private_key(key, prv) != 1)
//        goto cleanup;
//    if (EC_KEY_set_public_key(key, pub) != 1)
//        goto cleanup;
//
//    if (compressed) {
//        EC_KEY_set_conv_form(key, POINT_CONVERSION_COMPRESSED);
//        int length = i2o_ECPublicKey(key, &public_key->data);
//        public_key->length = length;
//        result = PTC_SUCCESS;
//    } else {
//        if (!ptc_buffer_create(public_key, 65)) {
//            result = PTC_ERROR_OUT_OF_MEMORY;
//            goto cleanup;
//        }
//        BIGNUM *n = BN_new();
//        EC_POINT_point2bn(group, pub, POINT_CONVERSION_UNCOMPRESSED, n, ctx);
//        BN_bn2bin(n, public_key->data);
//        BN_free(n);
//        result = PTC_SUCCESS;
//    }
//cleanup:
//    EC_POINT_free(pub);
//    BN_free(prv);
//    EC_KEY_free(key);
//    BN_CTX_free(ctx);
//    return result;
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
