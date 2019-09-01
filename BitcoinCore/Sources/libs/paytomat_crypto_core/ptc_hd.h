//
//  ptc_hd.h
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/24/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_HD_H
#define PTC_HD_H

#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include "ptc_result.h"
#include "ptc_buffer.h"

typedef struct ptc_hd_key {
    ptc_buffer private_key;
    ptc_buffer public_key;
    uint8_t chain_code[32];
    uint8_t depth;
    uint32_t fingerprint;
    uint32_t child_index;
} ptc_hd_key;

void ptc_hd_key_init(ptc_hd_key* hd_key);
bool ptc_hd_key_create(ptc_hd_key* hd_key,
                       const uint8_t* private_key,
                       size_t private_key_length,
                       const uint8_t* public_key,
                       size_t public_key_length,
                       const uint8_t* chain_code,
                       uint8_t depth,
                       uint32_t fingerprint,
                       uint32_t child_index);

void ptc_hd_key_destroy(ptc_hd_key* hd_key);

ptc_result ptc_hd_key_derive(const ptc_hd_key* src_hd_key,
                             uint32_t index,
                             bool hardened,
                             ptc_hd_key* dst_hd_key);

#endif
