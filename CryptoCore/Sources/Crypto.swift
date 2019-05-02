//
//  CryptoCore.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

public struct Crypto {
    public static func testPrint() {
        ptc_test_print()
    }
    
    public static func testInt() -> Int {
        return Int(ptc_test_int())
    }

    public static func keccak256(_ data: Data) -> Data? {
        guard !data.isEmpty else {
            return Data()
        }
        var p = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        p.initialize(to: 0)
        defer { p.deallocate() }
        let count = data.count
        let result: ptc_result = data.withUnsafeBytes {
            if let dataPtr = $0.bindMemory(to: UInt8.self).baseAddress {
                return ptc_keccak256(dataPtr, count, p)
            }
            return PTC_RESULT_ERROR_GENERAL
        }
        guard result == PTC_RESULT_SUCCESS else {
            return nil
        }
        return Data(bytes: p, count: 32)
    }
    
    
}
