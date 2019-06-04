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

    // MARK: Keccak
    
    @inline(__always)
    public static func keccak256(_ data: Data) -> Data? {
        return callCrypto(data, outCount: 32) { ptc_keccak256($0, $1, $2) }
    }
    
    // MARK: Blake2b
    
    @inline(__always)
    public static func blake2b(_ data: Data, outBytes: Int) -> Data? {
        return callCrypto(data, outCount: outBytes) { ptc_blake2b($0, $1, $2, outBytes) }
    }
    
    @inline(__always)
    public static func blake2b256(_ data: Data) -> Data? {
        return blake2b(data, outBytes: 32)
    }
    
    // MARK: SHA
    
    @inline(__always)
    public static func sha256(_ data: Data) -> Data? {
        return callCrypto(data, outCount: 32) { ptc_sha256($0, $1, $2) }
    }
    
    @inline(__always)
    public static func sha512(_ data: Data) -> Data? {
        return callCrypto(data, outCount: 64) { ptc_sha512($0, $1, $2) }
    }
    
    @inline(__always)
    public static func sha256sha256(_ data: Data) -> Data? {
        return callCrypto(data, outCount: 32) { ptc_sha256_sha256($0, $1, $2) }
    }
    
    // MARK: RIPEMD
    
    @inline(__always)
    public static func ripemd160(_ data: Data) -> Data? {
        return callCrypto(data, outCount: 20) { ptc_ripemd160($0, $1, $2) }
    }
    
    @inline(__always)
    public static func sha256ripemd160(_ data: Data) -> Data? {
        return callCrypto(data, outCount: 20) { ptc_sha256_ripemd160($0, $1, $2) }
    }
    
    // MARK: HMAC
    
    public static func hmacsha512(_ data: Data, key: Data) -> Data? {
        var out = Data(count: 64)
        let dataCount = data.count
        
        let keyCount = key.count
        let result: ptc_result = out.withUnsafeMutableBytes { outBuf in
            data.withUnsafeBytes { dataBuf in
                key.withUnsafeBytes { keyBuf in
                    if let dataPtr = dataBuf.baseAddress,
                        let keyPtr = keyBuf.baseAddress,
                        let outPtr = outBuf.bindMemory(to: UInt8.self).baseAddress {
                        return ptc_hmacsha512(dataPtr, dataCount, keyPtr, keyCount, outPtr)
                    }
                    return PTC_ERROR_GENERAL
                }
            }
        }
        return result == PTC_SUCCESS ? out : nil
    }
}

extension Crypto {
    @inline(__always)
    public static func callCrypto(_ data: Data,
                                  outCount: Int,
                                  callback: (UnsafeRawPointer, Int, UnsafeMutablePointer<UInt8>) -> ptc_result) -> Data? {
        guard outCount >= 0 else {
            fatalError("\(#function) outBytes cannot be negative")
        }
        var out = Data(count: outCount)
        let count = data.count
        let result: ptc_result = out.withUnsafeMutableBytes { outBuf in
            data.withUnsafeBytes { dataBuf in
                if let dataPtr = dataBuf.baseAddress,
                    let outPtr = outBuf.bindMemory(to: UInt8.self).baseAddress {
                    return callback(dataPtr, count, outPtr)
                }
                return PTC_ERROR_GENERAL
            }
        }
        return result == PTC_SUCCESS ? out : nil
    }
}
