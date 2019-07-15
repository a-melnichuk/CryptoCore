//
//  ptc_secp256k1.c
//  CryptoCore
//
//  Created by Alex Melnichuk on 7/12/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <secp256k1/_secp256k1.h>
#include <secp256k1/_secp256k1_recovery.h>
#include "ptc_secp256k1.h"
#include "ptc_key.h"
#include "ptc_crypto.h"

static int ptc_secp256k1_nonce_function(unsigned char *nonce32,
                                        const unsigned char *msg32,
                                        const unsigned char *key32,
                                        const unsigned char *algo16,
                                        void *data,
                                        unsigned int counter)
{
    unsigned char keydata[112];
    unsigned int offset = 0;
    secp256k1_rfc6979_hmac_sha256 rng;
    unsigned int i;
    /* We feed a byte array to the PRNG as input, consisting of:
     * - the private key (32 bytes) and message (32 bytes), see RFC 6979 3.2d.
     * - optionally 32 extra bytes of data, see RFC 6979 3.6 Additional Data.
     * - optionally 16 extra bytes with the algorithm name.
     * Because the arguments have distinct fixed lengths it is not possible for
     *  different argument mixtures to emulate each other and result in the same
     *  nonces.
     */
    
    
    buffer_append(keydata, &offset, key32, 32);
    
    int nonce = *((int*) data);
    if (nonce == 0)
        buffer_append(keydata, &offset, msg32, 32);
    else {
        int n = 32 + nonce;
        uint8_t* hash = malloc(n);
        memcpy(hash, msg32, 32);
        memset(hash + 32, 0, nonce);
        uint8_t sha256[32];
        ptc_sha256(hash, n, sha256);
        buffer_append(keydata, &offset, sha256, 32);
        free(hash);
    }
    
    if (algo16 != NULL) {
        buffer_append(keydata, &offset, algo16, 16);
    }
    
    secp256k1_rfc6979_hmac_sha256_initialize(&rng, keydata, offset);
    memset(keydata, 0, sizeof(keydata));
    for (i = 0; i <= counter; i++) {
        secp256k1_rfc6979_hmac_sha256_generate(&rng, nonce32, 32);
    }
    secp256k1_rfc6979_hmac_sha256_finalize(&rng);
    return 1;
}

ptc_result ptc_secp256k1_recoverable_sign_hash_sha256(const uint8_t* hash,
                                                      const uint8_t* private_key,
                                                      size_t private_key_length,
                                                      uint8_t* signature)
{
    if (!hash || !signature)
        return PTC_ERROR_NULL_ARGUMENT;
    ptc_result result = PTC_ERROR_GENERAL;
    uint8_t public_key[PTC_PUBLIC_KEY_COMPRESSED];
    if ((result = ptc_create_public_key(private_key, (int32_t) private_key_length, true, public_key)) != PTC_SUCCESS)
        return result;
    uint8_t data[32] = { 0 };
    memcpy(data, hash, 32);
    
    secp256k1_context* c = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY);
    int nonce = 0;
    
    while (1) {
        secp256k1_ecdsa_signature sig;
        if (secp256k1_ecdsa_sign(c, &sig, data, private_key, &ptc_secp256k1_nonce_function, &nonce) != 1) {
            result = PTC_ERROR_INVALID_SIGNATURE;
            goto cleanup;
        }
        
        secp256k1_ecdsa_signature sig_norm;
        secp256k1_ecdsa_signature_normalize(c, &sig_norm, &sig);
        uint8_t der[128];
        size_t der_lenth = 128;
        
        secp256k1_ecdsa_signature_serialize_der(c, der, &der_lenth, &sig_norm);
        
        uint8_t len_r = der[3];
        uint8_t len_s = der[5 + len_r];
        
        if (len_r == 32 && len_s == 32) {
            secp256k1_ecdsa_recoverable_signature rec_sig;
            memcpy(rec_sig.data, sig_norm.data, 64);
            
            for (int i = 0; i < 4; ++i) {
                rec_sig.data[64] = i;
                
                secp256k1_pubkey rec_pub_key;
                if (secp256k1_ecdsa_recover(c, &rec_pub_key, &rec_sig, data) != 1) {
                    result = PTC_ERROR_PUBKEY_SERIALIZATION_FAILED;
                    goto cleanup;
                }
                uint8_t rec_pub_key_compressed[PTC_PUBLIC_KEY_COMPRESSED];
                size_t rec_pub_key_compressed_size = PTC_PUBLIC_KEY_COMPRESSED;
                secp256k1_ec_pubkey_serialize(c, rec_pub_key_compressed, &rec_pub_key_compressed_size, &rec_pub_key, SECP256K1_EC_COMPRESSED);
                
                if (memcmp(rec_pub_key_compressed, public_key, PTC_PUBLIC_KEY_COMPRESSED) == 0) {
                    signature[0] = i;
                    // copy flipped r and s from DER signature
                    memcpy(signature + 1, der + 4, 32);
                    memcpy(signature + 33, der + 38 /* 5 + len_r (32) + 1 */, 32);
                    
                    result = PTC_SUCCESS;
                    goto cleanup;
                }
            }
            
            result = PTC_ERROR_PUBKEY_RESTORATION_FAILED;
            goto cleanup;
        }
        ++nonce;
    }
    
cleanup:
    secp256k1_context_destroy(c);
    return result;
}
