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
