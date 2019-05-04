//
//  CryptoCore.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core
import openssl
public struct Crypto {
    public static func testPrint() {
        ptc_test_print()
    }
    
    public static func testInt() -> Int {
        return Int(ptc_test_int())
    }

    // MARK: Keccak
    
    public static func keccak256(_ data: Data) -> Data? {
        var out = Data(count: 32)
        let count = data.count
        let result: ptc_result = out.withUnsafeMutableBytes { outBuf in
            data.withUnsafeBytes { dataBuf in
                if let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress,
                    let outPtr = outBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_keccak256(dataPtr, count, outPtr)
                }
                return PTC_RESULT_ERROR_GENERAL
            }
        }
        return result == PTC_RESULT_SUCCESS ? out : nil
    }
    
    // MARK: Blake2b
    
    public static func blake2b(_ data: Data, outBytes: Int) -> Data? {
        guard outBytes >= 0 else {
            fatalError("\(#function) outBytes cannot be negative")
        }
        var out = Data(count: outBytes)
        let dataCount = data.count
        let result: ptc_result = out.withUnsafeMutableBytes { outBuf in
            data.withUnsafeBytes { dataBuf in
                if let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress,
                    let outPtr = outBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_blake2b(dataPtr, dataCount, outPtr, outBytes)
                }
                return PTC_RESULT_ERROR_GENERAL
            }
        }
        return result == PTC_RESULT_SUCCESS ? out : nil
    }
    
    @inline(__always)
    public static func blake2b256(_ data: Data) -> Data? {
        return blake2b(data, outBytes: 32)
    }
    
    // MARK: SHA
    
    public static func sha256(_ data: Data) -> Data? {
        var out = Data(count: 32)
        let count = data.count
        let result: ptc_result = out.withUnsafeMutableBytes { outBuf in
            data.withUnsafeBytes { dataBuf in
                if let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress,
                    let outPtr = outBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_sha256(dataPtr, count, outPtr)
                }
                return PTC_RESULT_ERROR_GENERAL
            }
        }
        return result == PTC_RESULT_SUCCESS ? out : nil
    }
    
    public static func sha512(_ data: Data) -> Data? {
        var out = Data(count: 64)
        let count = data.count
        let result: ptc_result = out.withUnsafeMutableBytes { outBuf in
            data.withUnsafeBytes { dataBuf in
                if let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress,
                    let outPtr = outBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_sha512(dataPtr, count, outPtr)
                }
                return PTC_RESULT_ERROR_GENERAL
            }
        }
        return result == PTC_RESULT_SUCCESS ? out : nil
    }
    
}
