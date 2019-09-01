//
//  ptc_key.h
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/25/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_KEY_H
#define PTC_KEY_H

#include <stdio.h>
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include "ptc_result.h"
#include "ptc_buffer.h"

#define PTC_PUBLIC_KEY_COMPRESSED 33
#define PTC_PUBLIC_KEY_UNCOMPRESSED 65

ptc_result ptc_create_public_key(const uint8_t* private_key,
                                 int32_t private_key_length,
                                 bool compressed,
                                 uint8_t* public_key);

ptc_result ptc_derive_key(const uint8_t* password,
                          int32_t password_length,
                          const uint8_t* salt,
                          int32_t salt_length,
                          int32_t iterations,
                          int32_t key_length,
                          uint8_t* out_key);

#endif 
