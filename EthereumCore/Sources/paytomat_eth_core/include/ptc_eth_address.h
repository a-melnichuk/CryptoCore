//
//  ptc_eth_address.h
//  EthereumCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_ETH_ADDRESS_H
#define PTC_ETH_ADDRESS_H

#include <stddef.h>
#include <stdint.h>
#include <paytomat_crypto_core/ptc_result.h>

#define PTC_ETHEREUM_ECDSA_SERIALIZED_PUBKEY_BYTE_COUNT 64
#define PTC_ETHEREUM_ADDRESS_BYTE_COUNT 20
#define PTC_ETHEREUM_ADDRESS_KECCAK256_OFFSET 12 // last 20 bytes are taken, 32 - 20 = 12
#define PTC_ETHEREUM_ADDRESS_CHARACTER_COUNT 42  // warning: '\0' not included
#define PTC_ETHEREUM_ADDRESS_CHARACTER_COUNT_NO_SUFFIX 40

ptc_result ptc_eth_address(const void* in_pubkey, size_t public_key_length, char* out_address);
ptc_result ptc_eth_public_key(const void* in_privkey, size_t privkey_length, uint8_t* out_pubkey);

#endif 
