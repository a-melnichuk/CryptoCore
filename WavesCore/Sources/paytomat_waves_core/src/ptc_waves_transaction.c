//
//  ptc_waves_transaction.c
//  WavesCore
//
//  Created by Alex Melnichuk on 6/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <paytomat_crypto_core/ptc_util.h>
#include <paytomat_crypto_core/ptc_base58.h>
#include <paytomat_crypto_core/ptc_crypto.h>
#include "ptc_waves_address.h"
#include "ptc_waves_transaction.h"

void ptc_waves_serialized_transfer_tx_init(ptc_waves_serialized_transfer_tx* tx)
{
    if (!tx)
        return;
    tx->bytes = NULL;
    tx->length = 0;
    tx->timestamp = 0;
    memset(tx->public_key, 0, PTC_WAVES_PUBKEY_BYTE_COUNT);
}

void ptc_waves_serialized_transfer_tx_destroy(ptc_waves_serialized_transfer_tx* tx)
{
    if (!tx)
        return;
    if (tx->bytes) {
        memset(tx->bytes, 0, tx->length);
        free(tx->bytes);
    }
    tx->length = 0;
}

ptc_result ptc_waves_create_transfer_tx(const ptc_waves_transfer_tx_create_info* in_create_info,
                                               ptc_waves_serialized_transfer_tx* out_tx)
{
    if (!in_create_info
        || !(in_create_info->sender_privkey)
        || !(in_create_info->recipient_address)
        || !(in_create_info->time_offset)
        || !out_tx)
        return PTC_ERROR_NULL_ARGUMENT;
    
    ptc_result result = PTC_SUCCESS;
    
    uint8_t tx_type = PTC_WAVES_TX_TYPE_TRANSFER;
    int64_t timestamp = ptc_current_time_in_millis() + in_create_info->time_offset;
    
    int64_t amount = in_create_info->amount_wavelets;
    int64_t fee = in_create_info->fee_wavelets;
    int16_t attachment_length = in_create_info->attachment_length;
    if ((result = ptc_waves_public_key(in_create_info->sender_privkey, out_tx->public_key)) != PTC_SUCCESS)
        goto cleanup;

    uint8_t asset_id_flag = PTC_WAVES_ASSET_FLAG_WAVES;
    uint8_t fee_asset_id_flag = PTC_WAVES_ASSET_FLAG_WAVES;
    
    ptc_base58_context address, asset_id, fee_asset_id;
    
    bool asset_id_exists = in_create_info->asset_id && in_create_info->asset_id_length > 0;
    bool fee_asset_id_exists = in_create_info->fee_asset_id && in_create_info->fee_asset_id_length > 0;
    bool attachment_exists = in_create_info->attachment && in_create_info->attachment_length > 0;
    
    if (asset_id_exists) {
        if ((result = ptc_b58_decode(&asset_id,
                                     in_create_info->asset_id,
                                     in_create_info->asset_id_length)) != PTC_SUCCESS)
            goto cleanup;
        asset_id_flag = PTC_WAVES_ASSET_FLAG_ASSET;
    }
    
    if (fee_asset_id_exists) {
        if ((result = ptc_b58_decode(&fee_asset_id,
                                     in_create_info->fee_asset_id,
                                     in_create_info->fee_asset_id_length)) != PTC_SUCCESS)
            goto cleanup;
        fee_asset_id_flag = PTC_WAVES_ASSET_FLAG_ASSET;
    }
    
    // recipient encoding
    
    if ((result = ptc_b58_decode(&address,
                                 in_create_info->recipient_address,
                                 in_create_info->recipient_address_length)) != PTC_SUCCESS)
        goto cleanup;

    out_tx->timestamp = timestamp;
    
    if (ptc_is_little_endian()) {
        // swap endianness of variables, since Waves uses big-endian order
        timestamp         = ptc_swap_int64(timestamp);
        amount            = ptc_swap_int64(amount);
        fee               = ptc_swap_int64(fee);
        attachment_length = ptc_swap_int16(attachment_length);
    }
    
    // compute buffer size
    size_t sz_type           = sizeof(tx_type);
    size_t sz_pubkey         = PTC_WAVES_PUBKEY_BYTE_COUNT;
    size_t sz_asset_flag     = sizeof(asset_id_flag);
    size_t sz_asset          = asset_id.length;
    size_t sz_fee_asset_flag = sizeof(fee_asset_id_flag);
    size_t sz_fee_asset      = fee_asset_id.length;
    size_t sz_timestamp      = sizeof(timestamp);
    size_t sz_amount         = sizeof(amount);
    size_t sz_fee            = sizeof(fee);
    size_t sz_address        = address.length;
    size_t sz_att_len        = sizeof(attachment_length);
    size_t sz_att            = attachment_length;
    
    // compute buffer offsets
    size_t buffer_size        = 0;
    size_t off_type           = 0;
    size_t off_pubkey         = buffer_size += sz_type;
    size_t off_asset_flag     = buffer_size += sz_pubkey;
    size_t off_asset          = buffer_size += sz_asset_flag;
    size_t off_fee_asset_flag = buffer_size += sz_asset;
    size_t off_fee_asset      = buffer_size += sz_fee_asset_flag;
    size_t off_timestamp      = buffer_size += sz_fee_asset;
    size_t off_amount         = buffer_size += sz_timestamp;
    size_t off_fee            = buffer_size += sz_amount;
    size_t off_address        = buffer_size += sz_fee;
    size_t off_att_len        = buffer_size += sz_address;
    size_t off_att            = buffer_size += sz_att_len;
    buffer_size += sz_att;
    
    // fill buffer with data
    if ((out_tx->bytes = calloc(buffer_size, sizeof(uint8_t))) == NULL) {
        result = PTC_ERROR_OUT_OF_MEMORY;
        goto cleanup;
    }
    out_tx->length = buffer_size;
    uint8_t* bytes = out_tx->bytes;
    
    memcpy(bytes + off_type, &tx_type, sz_type);
    memcpy(bytes + off_pubkey, out_tx->public_key, sz_pubkey);
    memcpy(bytes + off_asset_flag, &asset_id_flag, sz_asset_flag);
    if (asset_id_exists)
        memcpy(bytes + off_asset, asset_id.bytes, sz_asset);
    memcpy(bytes + off_fee_asset_flag, &fee_asset_id_flag, sz_fee_asset_flag);
    if (fee_asset_id_exists)
        memcpy(bytes + off_fee_asset, fee_asset_id.bytes, sz_fee_asset);
    memcpy(bytes + off_timestamp, &timestamp, sz_timestamp);
    memcpy(bytes + off_amount, &amount, sz_amount);
    memcpy(bytes + off_fee, &fee, sz_fee);
    memcpy(bytes + off_address, address.bytes, sz_address);
    memcpy(bytes + off_att_len, &attachment_length, sz_att_len);
    if (attachment_exists)
        memcpy(bytes + off_att, &in_create_info->attachment, sz_att);
cleanup:
    ptc_b58_decode_destroy(&address);
    ptc_b58_decode_destroy(&asset_id);
    ptc_b58_decode_destroy(&fee_asset_id);
    return result;
}

ptc_result ptc_waves_transfer_tx_init(const ptc_waves_transfer_tx_create_info* in_create_info,
                                      ptc_waves_transfer_tx* out_transfer_tx)
{
    if (!in_create_info || !out_transfer_tx)
    return PTC_ERROR_NULL_ARGUMENT;
    
    ptc_result result = PTC_SUCCESS;
    
    out_transfer_tx->id = NULL;
    out_transfer_tx->id_length = 0;
    out_transfer_tx->signature = NULL;
    out_transfer_tx->signature_length = 0;
    out_transfer_tx->sender_public_key = NULL;
    out_transfer_tx->sender_public_key_length = 0;
    out_transfer_tx->attachment = NULL;
    out_transfer_tx->attachment_length = 0;
    
    ptc_waves_serialized_transfer_tx ser_tx;
    ptc_waves_serialized_transfer_tx_init(&ser_tx);
    if ((result = ptc_waves_create_transfer_tx(in_create_info, &ser_tx)) != PTC_SUCCESS)
        goto cleanup;
    
    out_transfer_tx->timestamp = ser_tx.timestamp;
    
    // parse id
    uint8_t id[32];
    if ((result = ptc_blake2b256(ser_tx.bytes, ser_tx.length, id)) != PTC_SUCCESS)
        goto cleanup;
    if ((result = ptc_b58_encode(id, 32, NULL, &out_transfer_tx->id_length)) != PTC_SUCCESS)
        goto cleanup;
    if ((out_transfer_tx->id = calloc(out_transfer_tx->id_length, sizeof(uint8_t))) == NULL) {
        result = PTC_ERROR_OUT_OF_MEMORY;
        goto cleanup;
    }
    if ((result = ptc_b58_encode(id, 32, out_transfer_tx->id, &out_transfer_tx->id_length)) != PTC_SUCCESS)
        goto cleanup;
    
    // parse pubkey
    if ((result = ptc_b58_encode(ser_tx.public_key,
                                 PTC_WAVES_PUBKEY_BYTE_COUNT,
                                 NULL,
                                 &out_transfer_tx->sender_public_key_length)) != PTC_SUCCESS)
        goto cleanup;
    if ((out_transfer_tx->sender_public_key = calloc(out_transfer_tx->sender_public_key_length,
                                                     sizeof(uint8_t))) == NULL) {
        result = PTC_ERROR_OUT_OF_MEMORY;
        goto cleanup;
    }
    if ((result = ptc_b58_encode(ser_tx.public_key,
                                 PTC_WAVES_PUBKEY_BYTE_COUNT,
                                 out_transfer_tx->sender_public_key,
                                 &out_transfer_tx->sender_public_key_length)) != PTC_SUCCESS)
        goto cleanup;
    
    // parse signature
    uint8_t signature[PTC_WAVES_SIGNATURE_BYTE_COUNT];
    if ((result = ptc_waves_sign(in_create_info->sender_privkey,
                                 ser_tx.bytes,
                                 ser_tx.length,
                                 signature)) != PTC_SUCCESS)
        goto cleanup;
    
    if ((result = ptc_b58_encode(signature,
                                 PTC_WAVES_SIGNATURE_BYTE_COUNT,
                                 NULL,
                                 &out_transfer_tx->signature_length)) != PTC_SUCCESS)
        goto cleanup;
    if ((out_transfer_tx->signature = calloc(out_transfer_tx->signature_length,
                                             sizeof(uint8_t))) == NULL) {
        result = PTC_ERROR_OUT_OF_MEMORY;
        goto cleanup;
    }
    if ((result = ptc_b58_encode(signature,
                                 PTC_WAVES_SIGNATURE_BYTE_COUNT,
                                 out_transfer_tx->signature,
                                 &out_transfer_tx->signature_length)) != PTC_SUCCESS)
        goto cleanup;
    // parse attachment
    if ((result = ptc_b58_encode(in_create_info->attachment,
                      in_create_info->attachment_length,
                      NULL,
                      &out_transfer_tx->attachment_length)) != PTC_SUCCESS)
        goto cleanup;
    if ((out_transfer_tx->attachment = calloc(out_transfer_tx->attachment_length,
                                              sizeof(uint8_t))) == NULL) {
        result = PTC_ERROR_OUT_OF_MEMORY;
        goto cleanup;
    }
    if ((result = ptc_b58_encode(in_create_info->attachment,
                                 in_create_info->attachment_length,
                                 out_transfer_tx->attachment,
                                 &out_transfer_tx->attachment_length)) != PTC_SUCCESS)
        goto cleanup;
cleanup:
    ptc_waves_serialized_transfer_tx_destroy(&ser_tx);
    return result;
}

void ptc_waves_make_transfer_tx_destroy(ptc_waves_transfer_tx* in_transfer_tx)
{
    if (!in_transfer_tx)
        return;
    free(in_transfer_tx->signature);
    free(in_transfer_tx->sender_public_key);
    free(in_transfer_tx->attachment);
}

ptc_result ptc_waves_sign(const void* in_private_key,
                          const uint8_t* in_data,
                          size_t in_length,
                          uint8_t* out_signature) {
    ptc_result result = PTC_ERROR_GENERAL;
    uint8_t random_bytes[PTC_WAVES_SIGNATURE_RANDOM_BYTES];
    if ((result = ptc_random_bytes(random_bytes, PTC_WAVES_SIGNATURE_RANDOM_BYTES)) != PTC_SUCCESS)
        return result;
    return ptc_xed25519_sign(in_private_key,
                             in_data,
                             in_length,
                             random_bytes,
                             out_signature);
}
