//
//  ptc_trx_transaction.h
//  TRONCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_TRX_TRANSACTION_H
#define PTC_TRX_TRANSACTION_H

#define PTC_TRX_SIGNATURE_BYTE_COUNT 65

#include <stdio.h>
#include <paytomat_crypto_core/ptc_result.h>
#include <paytomat_crypto_core/ptc_util.h>
#include <paytomat_crypto_core/ptc_crypto.h>
#include <string.h>

ptc_result ptc_trx_sign_transaction(const uint8_t* in_data, size_t in_length,
                                    const uint8_t* in_privkey, size_t in_privkey_length,
                                    uint8_t* out_signature);

#endif
