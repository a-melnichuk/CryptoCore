//
//  ptc_result+Extension.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

extension ptc_result: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case PTC_SUCCESS:
            return "PTC_SUCCESS"
        case PTC_ERROR_INVALID_PARAM:
            return "PTC_ERROR_INVALID_PARAM"
        case PTC_ERROR_INVALID_PRIVATE_KEY:
            return "PTC_ERROR_INVALID_PRIVATE_KEY"
        case PTC_ERROR_PUBKEY_CREATION_FAILED:
            return "PTC_ERROR_PUBKEY_CREATION_FAILED"
        case PTC_ERROR_PUBKEY_SERIALIZATION_FAILED:
            return "PTC_ERROR_PUBKEY_SERIALIZATION_FAILED"
        case PTC_ERROR_OUT_OF_MEMORY:
            return "PTC_ERROR_OUT_OF_MEMORY"
        case PTC_ERROR_NULL_ARGUMENT:
            return "PTC_ERROR_NULL_ARGUMENT"
        case PTC_ERROR_INVALID_SIGNATURE:
            return "PTC_ERROR_INVALID_SIGNATURE"
        case PTC_ERROR_INVALID_SIZE:
            return "PTC_ERROR_INVALID_SIZE"
        case PTC_ERROR_SHA256_FAILED:
            return "PTC_ERROR_SHA256_FAILED"
        case PTC_ERROR_INVALID_CHECKSUM:
            return "PTC_ERROR_INVALID_CHECKSUM"
        case PTC_ERROR_INVALID_INPUTS:
            return "PTC_ERROR_INVALID_INPUTS"
        case PTC_ERROR_INVALID_PUBKEYHASH:
            return "PTC_ERROR_INVALID_PUBKEYHASH"
        case PTC_ERROR_PARSE:
            return "PTC_ERROR_PARSE"
        case PTC_ERROR_PUBKEY_RESTORATION_FAILED:
            return "PTC_ERROR_PUBKEY_RESTORATION_FAILED"
        case PTC_ERROR_GENERAL:
            return "PTC_ERROR_GENERAL"
        default:
            return "<Unknown>"
        }
    }
}
