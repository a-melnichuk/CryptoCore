//
//  CryptoCoreUtil.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

public struct CryptoUtil {
    public static func data(fromHex hex: String) -> Data? {
        guard !hex.isEmpty else {
            return Data()
        }
        let count = hex.count
        let byteCount = hex.count / 2
        var p = UnsafeMutablePointer<UInt8>.allocate(capacity: byteCount)
        p.initialize(to: 0)
        defer { p.deallocate() }
        let success = hex.withCString { hexPtr in
            ptc_from_hex(hexPtr, count, p)
        }
        return success ? Data(bytes: p, count: byteCount) : nil
    }
    
    public static func hex(fromData data: Data) -> String {
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
}
