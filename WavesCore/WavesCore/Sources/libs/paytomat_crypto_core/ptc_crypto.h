//
//  ptc_crypto.h
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_CRYPTO_H
#define PTC_CRYPTO_H

#include <stddef.h>
#include <stdint.h>

#include "ptc_result.h"

// Keccak

ptc_result ptc_keccak256(const void* in_data, size_t in_length, uint8_t* out_bytes);
ptc_result ptc_keccak512(const void* in_data, size_t in_length, uint8_t* out_bytes);

// Blake2b

ptc_result ptc_blake2b(const void* in_data, size_t in_length, uint8_t* out_bytes, size_t out_length);
ptc_result ptc_blake2b256(const void* in_data, size_t in_length, uint8_t* out_bytes);

// SHA

ptc_result ptc_sha256(const void* in_data, size_t in_length, uint8_t* out_bytes);
ptc_result ptc_sha512(const void* in_data, size_t in_length, uint8_t* out_bytes);
ptc_result ptc_sha256_sha256(const void* in_data, size_t in_length, uint8_t* out_bytes);

// RIPEMD

ptc_result ptc_ripemd160(const void* in_data, size_t in_length, uint8_t* out_bytes);
ptc_result ptc_sha256_ripemd160(const void* in_data, size_t in_length, uint8_t* out_bytes);

// HMAC

ptc_result ptc_hmacsha512(const void* in_data,
                          size_t in_data_length,
                          const void* in_key,
                          size_t in_key_length,
                          uint8_t* out_bytes);

// Curve25519-Donna

ptc_result ptc_curve25519_donna(const void* in_privkey, const uint8_t* in_basepoint, uint8_t* out_pubkey);

// xed25519

ptc_result ptc_xed25519_sign(const uint8_t* curve25519_privkey,
                             const uint8_t* msg,
                             const size_t msg_len,
                             const uint8_t* random,
                             uint8_t* signature_out);

#endif
