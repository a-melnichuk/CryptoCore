//
//  Base58.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/5/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

public struct Base58 {
    
    private init() {}
    
    public static func check(encode data: Data, version: [UInt8]) -> String? {
        guard !data.isEmpty, !version.isEmpty else {
            return nil
        }
        var size: size_t = 0
        let dataCount = data.count
        let versionCount = version.count
        _ = data.withUnsafeBytes { dataBuf in
            version.withUnsafeBytes { versionBuf in
                guard let versionPtr = versionBuf.bindMemory(to: UInt8.self).baseAddress else {
                    return
                }
                ptc_b58check_encode(dataBuf.baseAddress, dataCount, versionPtr, versionCount, nil, &size)
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
                return ptc_b58check_encode(dataBuf.baseAddress, dataCount, versionPtr, versionCount, p, &size)
            }
        }
        return result == PTC_SUCCESS ? String(cString: p) : nil
    }
    
    public static func check(decode string: String, version: [UInt8]) -> Data? {
        guard !string.isEmpty, !version.isEmpty else {
            return nil
        }
        var c = ptc_base58_context()
        defer { ptc_b58_decode_destroy(&c) }
        let count = version.count
        let result: ptc_result = version.withUnsafeBytes { versionBuf in
            string.withCString { strPtr in
                if let versionPtr = versionBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_b58check_decode(&c, strPtr, versionPtr , count)
                }
                return PTC_ERROR_GENERAL
            }
        }
        return result == PTC_SUCCESS ? Data(bytes: c.bytes, count: c.length) : nil
    }
    
    public static func encode(_ data: Data) -> String? {
        guard !data.isEmpty else {
            return nil
        }
        var size: size_t = 0
        let count = data.count
        _ = data.withUnsafeBytes {
            ptc_b58_encode($0.baseAddress, count, nil, &size)
        }
        guard size > 0 else {
            return nil
        }
        var p = UnsafeMutablePointer<CChar>.allocate(capacity: size)
        p.initialize(to: 0)
        defer { p.deallocate() }
        let result = data.withUnsafeBytes {
            ptc_b58_encode($0.baseAddress, data.count, p, &size)
        }
        return result == PTC_SUCCESS ? String(cString: p) : nil
    }
    
    public static func decode(_ string: String) -> Data? {
        guard !string.isEmpty else {
            return nil
        }
        var c = ptc_base58_context()
        defer { ptc_b58_decode_destroy(&c) }
        let count = string.count
        let result = string.withCString {
            ptc_b58_decode(&c, $0, count)
        }
        return result == PTC_SUCCESS ? Data(bytes: c.bytes, count: c.length) : nil
    }
    
    public static func check(string: String, version: [UInt8]) -> Bool {
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

