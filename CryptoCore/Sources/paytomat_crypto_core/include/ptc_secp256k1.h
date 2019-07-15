//
//  ptc_secp256k1.h
//  CryptoCore
//
//  Created by Alex Melnichuk on 7/12/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_SECP256K1_H
#define ptc_secp256k1_h

#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include "ptc_result.h"

ptc_result ptc_secp256k1_recoverable_sign_hash_sha256(const uint8_t* hash,
                                                      const uint8_t* private_key,
                                                      size_t private_key_length,
                                                      uint8_t* signature);

#endif /* ptc_secp256k1_h */
