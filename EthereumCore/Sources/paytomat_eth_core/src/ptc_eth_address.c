//
//  ptc_eth_address.c
//  EthereumCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <string.h>
#include <paytomat_crypto_core/ptc_crypto.h>
#include <paytomat_crypto_core/ptc_key.h>
#include <paytomat_crypto_core/ptc_util.h>
#include "ptc_eth_address.h"

ptc_result ptc_eth_address(const void* in_pubkey, size_t public_key_length, char* out_address)
{
    uint8_t keccak_bytes[32];
    ptc_result keccak_result = ptc_keccak256(in_pubkey, public_key_length, keccak_bytes);
    if (keccak_result != PTC_SUCCESS)
        return keccak_result;
    
    uint8_t out_address_bytes[PTC_ETHEREUM_ADDRESS_BYTE_COUNT];
    memcpy(out_address_bytes, keccak_bytes + PTC_ETHEREUM_ADDRESS_KECCAK256_OFFSET, PTC_ETHEREUM_ADDRESS_BYTE_COUNT);
    out_address[0] = '0';
    out_address[1] = 'x';
    ptc_to_hex(out_address_bytes, PTC_ETHEREUM_ADDRESS_BYTE_COUNT, out_address + 2);
    return PTC_SUCCESS;
}

ptc_result ptc_eth_public_key(const void* in_privkey, size_t privkey_length, uint8_t* out_pubkey)
{
    uint8_t ecdsa_bytes[65];
    ptc_result result = ptc_create_public_key(in_privkey, (int32_t) privkey_length, false, ecdsa_bytes);
    if (result != PTC_SUCCESS)
        return result;
    memcpy(out_pubkey, ecdsa_bytes + 1, PTC_ETHEREUM_ECDSA_SERIALIZED_PUBKEY_BYTE_COUNT);
    return PTC_SUCCESS;
}
