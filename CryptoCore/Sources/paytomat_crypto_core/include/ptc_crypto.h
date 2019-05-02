//
//  ptc_crypto.h
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_CRYPTO_H
#define PTC_CRYPTO_H

#include <stdint.h>
#include <keccak-tiny/keccak-tiny.h>

#include "ptc_result.h"

ptc_result ptc_keccak256(const void* in_data, size_t in_length, uint8_t* out_bytes);
ptc_result ptc_keccak512(const void* in_data, size_t in_length, uint8_t* out_bytes);

#endif
