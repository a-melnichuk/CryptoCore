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
    
    @available(*, deprecated, message: "Use Base58Check.encode")
    public static func check(encode data: Data, version: [UInt8]) -> String? {
        return Base58Check.encode(data, version: version)
    }
    
    @available(*, deprecated, message: "Use Base58Check.decode")
    public static func check(decode string: String, version: [UInt8]) -> Data? {
        return Base58Check.decode(string, version: version)
    }
    
    @available(*, deprecated, message: "Use Base58Check.valid")
    public static func check(string: String, version: [UInt8]) -> Bool {
        return Base58Check.valid(string, version: version)
    }
    
    public static func encode(_ data: Data) -> String? {
        guard !data.isEmpty else {
            return nil
        }
        var size: size_t = 0
        _ = data.withUnsafeBytes {
            ptc_b58_encode($0.baseAddress, $0.count, nil, &size)
        }
        guard size > 0 else {
            return nil
        }
        var p = UnsafeMutablePointer<CChar>.allocate(capacity: size)
        p.initialize(to: 0)
        defer { p.deallocate() }
        let result = data.withUnsafeBytes {
            ptc_b58_encode($0.baseAddress, $0.count, p, &size)
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
    
    
}

