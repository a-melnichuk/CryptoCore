//
//  Key.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/25/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

public extension Crypto {
    struct Key {
        private init() {}
    }
}

public extension Crypto.Key {
    static func derive(password: Data, salt: Data, iterations: Int32, keyLength: Int32) -> Data? {
        var data = Data(count: Int(keyLength))
        let result: ptc_result = data.withUnsafeMutableBytes { dataBuf in
            return password.withUnsafeBytes { passwordBuf in
                return salt.withUnsafeBytes { saltBuf in
                    if let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress,
                        let passwordPtr = passwordBuf.bindMemory(to: UInt8.self).baseAddress,
                        let saltPtr = saltBuf.bindMemory(to: UInt8.self).baseAddress {
                        return ptc_derive_key(passwordPtr,
                                              Int32(passwordBuf.count),
                                              saltPtr,
                                              Int32(saltBuf.count),
                                              iterations,
                                              keyLength,
                                              dataPtr)
                    }
                    return PTC_ERROR_GENERAL
                }
            }
        }
        return result == PTC_SUCCESS ? data : nil
    }
    
    static func publicKey(from privateKey: Data, compressed: Bool) -> Data? {
        var publicKey = ptc_buffer()
        ptc_buffer_init(&publicKey)
        defer { ptc_buffer_destroy(&publicKey) }
        let result: ptc_result = privateKey.withUnsafeBytes { privateKeyBuf in
            if let privateKeyPtr = privateKeyBuf.bindMemory(to: UInt8.self).baseAddress {
                return ptc_create_public_key(privateKeyPtr,
                                             Int32(privateKeyBuf.count),
                                             compressed,
                                             &publicKey)
            }
            return PTC_ERROR_GENERAL
        }
        guard result == PTC_SUCCESS else {
            return nil
        }
        return Data(bytes: publicKey.data, count: publicKey.length)
    }
}
