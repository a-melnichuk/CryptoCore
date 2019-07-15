//
//  ptc_waves_address.h
//  WavesCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_WAVES_ADDRESS_H
#define PTC_WAVES_ADDRESS_H

#include <stddef.h>
#include <stdint.h>
#include <paytomat_crypto_core/ptc_result.h>

#define PTC_WAVES_BASEPOINT_BYTE_COUNT 32
#define PTC_WAVES_PUBKEY_BYTE_COUNT 32
#define PTC_WAVES_ADDRESS_BYTE_COUNT 26
#define PTC_WAVES_ADDRESS_CHECKSUM_BYTE_COUNT 4

ptc_result ptc_waves_public_key(const void* in_privkey, uint8_t* out_pubkey);
ptc_result ptc_waves_address(const void* in_pubkey, uint8_t in_scheme, uint8_t* out_address_bytes);
ptc_result ptc_waves_address_valid(const char* in_address, uint8_t in_scheme);

#endif 
