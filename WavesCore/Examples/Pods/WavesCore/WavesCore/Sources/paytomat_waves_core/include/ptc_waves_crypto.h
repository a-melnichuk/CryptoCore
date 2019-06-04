//
//  ptc_waves_crypto.h
//  WavesCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_WAVES_CRYPTO_H
#define PTC_WAVES_CRYPTO_H

#include <stddef.h>
#include <stdint.h>
#include <paytomat_crypto_core/ptc_result.h>

#define PTC_WAVES_SECURE_HASH_BYTE_COUNT 32

ptc_result ptc_waves_secure_hash(const void* in_data, size_t in_length, uint8_t* out_bytes);

#endif 
