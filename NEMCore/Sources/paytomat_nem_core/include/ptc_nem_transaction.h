//
//  ptc_nem_transaction.h
//  NEMCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_NEM_TRANSACTION_H
#define PTC_NEM_TRANSACTION_H

#include <stddef.h>
#include <stdint.h>
#include <paytomat_crypto_core/ptc_result.h>

#define PTC_NEM_SIGNATURE_PART_BYTE_COUNT 32
#define PTC_NEM_SIGNATURE_BYTE_COUNT 64

ptc_result ptc_nem_sign(const void* in_private_key,
                        const uint8_t* in_data,
                        size_t in_length,
                        uint8_t* out_signature);

#endif 
