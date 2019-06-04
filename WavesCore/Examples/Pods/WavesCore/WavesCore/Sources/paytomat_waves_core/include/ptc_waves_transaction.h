//
//  ptc_waves_transaction.h
//  WavesCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#ifndef PTC_WAVES_TRANSACTION_H
#define PTC_WAVES_TRANSACTION_H

#include <stddef.h>
#include <stdint.h>
#include <paytomat_crypto_core/ptc_result.h>

#define PTC_WAVES_TX_TYPE_TRANSFER 4
#define PTC_WAVES_MIN_TRANSFER_TX_BUFFER_SIZE_BYTE_COUNT 120
#define PTC_WAVES_ASSET_BYTE_COUNT 32
#define PTC_WAVES_ASSET_WAVES_NAME "Waves"
#define PTC_WAVES_ASSET_FLAG_WAVES 0
#define PTC_WAVES_ASSET_FLAG_ASSET 1
#define PTC_WAVES_SIGNATURE_BYTE_COUNT 64
#define PTC_WAVES_SIGNATURE_RANDOM_BYTES 64

/*
 Request params for:
 POST /assets/broadcast/transfer
 
 "assetId" [optional] - Asset ID to transfer or omit that param when transfer WAVES, Base58-encoded
 "senderPublicKey" - Sender account's public key, Base58-encoded
 "recipient" - Recipient account's address, Base58-encoded
 "fee" - Transaction fee for Asset transfer, min = 100000 (WAVElets)
 "feeAssetId" [optional] - Asset ID of transaction fee. WAVES by default, if empty or absent
 "amount" - amount of asset'lets (or wavelets) to transfer
 "attachment" - Arbitrary additional data included in transaction, max length is 140 bytes, Base58-encoded
 "timestamp" - Transaction timestamp
 "signature" - Signature of all transaction data, Base58-encoded
 
 */

/*
 
 Transfer transaction:
 
 #    Field name                                 Type     Position                    Length
 1    Transaction type (0x04)                    Byte     0                           1
 2    Signature                                  Bytes    1                           64
 3    Transaction type (0x04)                    Byte     65                          1
 4    Sender's public key                        Bytes    66                          32
 5    Amount's asset flag (0-Waves, 1-Asset)     Byte     98                          1
 6    Amount's asset ID (*if used)               Bytes    99                          0 (32*)
 7    Fee's asset flag (0-Waves, 1-Asset)        Byte     99 (131*)                   1
 8    Fee's asset ID (**if used)                 Bytes    100 (132*)                  0 (32**)
 9    Timestamp                                  Long     100 (132*) (164**)          8
 10   Amount                                     Long     108 (140*) (172**)          8
 11   Fee                                        Long     116 (148*) (180**)          8
 12   Recipient's AddressOrAlias object bytes    Bytes    124 (156*) (188**)          M
 13   Attachment's length (N)                    Short    124+M (156+M*) (188+M**)    2
 14   Attachment's bytes                         Bytes    126+M (158+M*) (190+M**)    N
 
 
 The transaction's signature is calculated from the following bytes:
 
 #    Field name                                Type    Position                  Length
 1    Transaction type (0x04)                   Byte    0                         1
 2    Sender's public key                       Bytes   1                         32
 3    Amount's asset flag (0-Waves, 1-Asset)    Byte    33                        1
 4    Amount's asset ID (*if used)              Bytes   34                        0 (32*)
 5    Fee's asset flag (0-Waves, 1-Asset)       Byte    34 (66*)                  1
 6    Fee's asset ID (**if used)                Bytes   35 (67*)                  0 (32**)
 7    Timestamp                                 Long    35 (67*) (99**)           8
 8    Amount                                    Long    43 (75*) (107**)          8
 9    Fee                                       Long    51 (83*) (115**)          8
 10   Recipient's AddressOrAlias object bytes   Bytes   59 (91*) (123**)          M
 11   Attachment's length (N)                   Short   59+M (91+M*) (123+M**)    2
 12   Attachment's bytes                        Bytes   61+M (93+M*) (125+M**)    N
 
 */

typedef struct ptc_waves_transfer_tx_create_info {
    uint8_t* sender_privkey;
    char* recipient_address;
    size_t recipient_address_length;
    int64_t amount_wavelets;
    int64_t fee_wavelets;
    char* asset_id; // nullable
    size_t asset_id_length;
    char* fee_asset_id; // nullable
    size_t fee_asset_id_length;
    uint8_t* attachment; // nullable
    int16_t attachment_length;
    int64_t time_offset;
} ptc_waves_transfer_tx_create_info;

typedef struct ptc_waves_transfer_tx {
    char* id;
    size_t id_length;
    char* sender_public_key; // base58 endcoded
    size_t sender_public_key_length;
    char* signature;
    size_t signature_length;
    //uint8_t signature[PTC_WAVES_SIGNATURE_BYTE_COUNT]; // base58 encoded
    char* attachment; // nullable, base58 endcoded
    size_t attachment_length;
    int64_t timestamp;
} ptc_waves_transfer_tx;

typedef struct ptc_waves_serialized_transfer_tx {
    uint8_t* bytes;
    size_t length;
    int64_t timestamp;
    uint8_t public_key[PTC_WAVES_PUBKEY_BYTE_COUNT];
} ptc_waves_serialized_transfer_tx;

ptc_result ptc_waves_transfer_tx_init(const ptc_waves_transfer_tx_create_info* in_create_info,
                                      ptc_waves_transfer_tx* out_transfer_tx);

void ptc_waves_make_transfer_tx_destroy(ptc_waves_transfer_tx* in_transfer_tx);

ptc_result ptc_waves_sign(const void* in_private_key,
                          const uint8_t* in_data,
                          size_t in_length,
                          uint8_t* out_signature);

// Transfer transaction

void ptc_waves_serialized_transfer_tx_init(ptc_waves_serialized_transfer_tx* tx);

ptc_result ptc_waves_create_transfer_tx(const ptc_waves_transfer_tx_create_info* in_create_info,
                                        ptc_waves_serialized_transfer_tx* out_tx);

void ptc_waves_serialized_transfer_tx_destroy(ptc_waves_serialized_transfer_tx* tx);
#endif 
