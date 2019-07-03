//
//  Hex.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/30/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

public struct Hex {
    public static func encode(_ data: Data) -> String {
        guard !data.isEmpty else {
            return ""
        }
        let byteCount = data.count * 2 + 1
        var p = UnsafeMutablePointer<CChar>.allocate(capacity: byteCount)
        p.initialize(to: 0)
        defer { p.deallocate() }
        data.withUnsafeBytes {
            if let ptr = $0.bindMemory(to: UInt8.self).baseAddress {
                ptc_to_hex(ptr, data.count, p)
            }
        }
        return String(cString: p)
    }
    
    public static func decode(_ hex: String) -> Data? {
        guard !hex.isEmpty else {
            return Data()
        }
        let count = hex.count
        var data = Data(count: hex.count / 2)
        let success: Bool = data.withUnsafeMutableBytes { dataBuf in
            if let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress {
                return hex.withCString { hexPtr in
                    ptc_from_hex(hexPtr, count, dataPtr)
                }
            }
            return false
        }
        return success ? data : nil
    }
    
    private init() {}
}
