//
//  Base58Check.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 8/29/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

public struct Base58Check {
    private init() {}
    
    public static func encode(_ data: Data, version: [UInt8]) -> String? {
        guard !data.isEmpty, !version.isEmpty else {
            return nil
        }
        var size: size_t = 0
        _ = data.withUnsafeBytes { dataBuf in
            version.withUnsafeBytes { versionBuf in
                guard let versionPtr = versionBuf.bindMemory(to: UInt8.self).baseAddress else {
                    return
                }
                ptc_b58check_encode(dataBuf.baseAddress, dataBuf.count, versionPtr, versionBuf.count, nil, &size)
            }
        }
        guard size > 0 else {
            return nil
        }
        var p = UnsafeMutablePointer<CChar>.allocate(capacity: size)
        p.initialize(to: 0)
        defer { p.deallocate() }
        let result: ptc_result = data.withUnsafeBytes { dataBuf in
            version.withUnsafeBytes { versionBuf in
                guard let versionPtr = versionBuf.bindMemory(to: UInt8.self).baseAddress else {
                    return PTC_ERROR_GENERAL
                }
                return ptc_b58check_encode(dataBuf.baseAddress, dataBuf.count, versionPtr, versionBuf.count, p, &size)
            }
        }
        return result == PTC_SUCCESS ? String(cString: p) : nil
    }
    
    public static func decode(_ string: String, version: [UInt8]) -> Data? {
        guard !string.isEmpty, !version.isEmpty else {
            return nil
        }
        var c = ptc_base58_context()
        defer { ptc_b58_decode_destroy(&c) }
        let result: ptc_result = version.withUnsafeBytes { versionBuf in
            string.withCString { strPtr in
                if let versionPtr = versionBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_b58check_decode(&c, strPtr, versionPtr, versionBuf.count)
                }
                return PTC_ERROR_GENERAL
            }
        }
        guard result == PTC_SUCCESS else {
            return nil
        }
        return Data(bytes: c.bytes, count: c.length)
            .dropFirst(version.count)
            .dropLast(4)
    }
    
    public static func valid(_ string: String, version: [UInt8]) -> Bool {
        guard !version.isEmpty, !string.isEmpty else {
            return false
        }
        let count = version.count
        let result: ptc_result = string.withCString { strPtr in
            version.withUnsafeBytes { versionBuf in
                if let versionPtr = versionBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_b58check(strPtr, versionPtr, count)
                }
                return PTC_ERROR_GENERAL
            }
        }
        return result == PTC_SUCCESS
    }
}
