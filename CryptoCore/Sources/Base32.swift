//
//  Base32.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

public struct Base32 {
    
    private init() {}
    
    public static func encode(_ data: Data) -> String? {
        let size = ptc_b32_encoded_length(data.count)
        var encoded = Data(count: size)
        let result: ptc_result = encoded.withUnsafeMutableBytes { encodedBuf in
            return data.withUnsafeBytes { dataBuf in
                if let encodedPtr = encodedBuf.bindMemory(to: UInt8.self).baseAddress,
                    let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_b32_encode(dataPtr, data.count, encodedPtr)
                }
                return PTC_ERROR_GENERAL
            }
        }
        guard result == PTC_SUCCESS else { return nil }
        return String(data: encoded, encoding: .nonLossyASCII)
    }
    
    public static func decode(_ string: String) -> Data? {
        guard let charArray = string.cString(using: .nonLossyASCII) else {
            return nil
        }
        let size = ptc_b32_decoded_length(charArray.count)
        var decoded = Data(count: size)
        var stringLength = 0
        let result: ptc_result = decoded.withUnsafeMutableBytes { decodedBuf in
            return charArray.withUnsafeBytes { charBuf in
                if let decodedPtr = decodedBuf.bindMemory(to: Int8.self).baseAddress,
                    let charPtr = charBuf.bindMemory(to: Int8.self).baseAddress {
                    let result = ptc_b32_decode(charPtr, size, decodedPtr)
                    stringLength = strlen(decodedPtr)
                    return result
                }
                return PTC_ERROR_GENERAL
            }
        }
        guard result == PTC_SUCCESS else { return nil }
        return decoded.prefix(stringLength)
    }
}
