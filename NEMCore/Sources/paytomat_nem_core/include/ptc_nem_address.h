//
//  ptc_waves_address.h
//  NEMCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_NEM_ADDRESS_H
#define PTC_NEM_ADDRESS_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <paytomat_crypto_core/ptc_result.h>

#define PTC_NEM_PRIVKEY_PART_BYTE_COUNT 32
#define PTC_NEM_PRIVKEY_HEX_CHAR_COUNT 64
#define PTC_NEM_PRIVKEY_BYTE_COUNT 64
#define PTC_NEM_PUBKEY_BYTE_COUNT 32
#define PTC_NEM_ADDRESS_DECODED_BYTE_COUNT 25
#define PTC_NEM_ADDRESS_ENCODED_CHAR_COUNT 40
#define PTC_NEM_ADDRESS_ENCODED_NORMALIZED_CHAR_COUNT 46
#define PTC_NEM_ADDRESS_CHECKSUM_BYTE_COUNT 4

ptc_result ptc_nem_public_key(const void* in_privkey, uint8_t* out_pubkey);
ptc_result ptc_nem_address(const void* in_pubkey, uint8_t in_scheme, uint8_t* out_address_bytes);
void ptc_nem_address_normalize(const char* in_address, char* out_normalized_address);
void ptc_nem_address_denormalize(const char* in_address,
                                 size_t* out_normalized_address_length,
                                 char* out_normalized_address);



#endif 
