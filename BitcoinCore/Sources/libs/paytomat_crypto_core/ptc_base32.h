//
//  ptc_base32.h
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_BASE32_H
#define PTC_BASE32_H

#include <stdlib.h>
#include <stdint.h>
#include "ptc_result.h"

ptc_result ptc_b32_encode(const void* in_data, size_t in_length, uint8_t *out_bytes);
ptc_result ptc_b32_decode(const void* in_data, size_t in_length, int8_t* out_bytes);
size_t ptc_b32_encoded_length(size_t in_length);
size_t ptc_b32_decoded_length(size_t in_length);

#endif
