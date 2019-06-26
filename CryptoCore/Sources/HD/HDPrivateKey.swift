//
//  HDPrivateKey.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/24/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

public class HDPrivateKey {
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32
    private(set) public var raw: Data
    public let chainCode: Data
    
    public convenience init?(seed: Seed) {
        let key = "Bitcoin seed".data(using: .ascii)!
        guard let hmac = Crypto.hmacsha512(seed.raw, key: key) else {
            return nil
        }
        let privateKey = hmac[0..<32]
        let chainCode = hmac[32..<64]
        self.init(privateKey: privateKey, chainCode: chainCode)
    }
    
    public init(privateKey: Data,
                chainCode: Data,
                depth: UInt8 = 0,
                fingerprint: UInt32 = 0,
                childIndex: UInt32 = 0) {
        self.raw = privateKey.resized(minimumLength: 32)
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }
    
    deinit {
        zeroOut()
    }
    
    public func publicKey() -> HDPublicKey? {
        return HDPublicKey(privateKey: self,
                           chainCode: chainCode,
                           depth: depth,
                           fingerprint: fingerprint,
                           childIndex: childIndex)
    }
    
    public func derived(for path: String) -> HDPrivateKey? {
        var key = self
        
        var path = path
        if path == "m" || path == "/" || path == "" {
            return key
        }
        if path.contains("m/") {
            path = String(path.dropFirst(2))
        }
        for chunk in path.split(separator: "/") {
            var hardened = false
            var indexText = chunk
            if chunk.contains("'") {
                hardened = true
                indexText = indexText.dropLast()
            }
            guard let index = UInt32(indexText) else {
                fatalError("invalid path")
            }
            guard let derivedKey = key.derived(at: index, hardened: hardened) else {
                return nil
            }
            key = derivedKey
        }
        return key
    }
    
    public func derived(at index: UInt32, hardened: Bool = false) -> HDPrivateKey? {
        // As we use explicit parameter "hardened", do not allow higher bit set.
        if (0x80000000 & index) != 0 {
            fatalError("invalid child index")
        }
        
        guard var hdKey = ptc_hd_key(privateKey: self) else {
            return nil
        }
        defer { ptc_hd_key_destroy(&hdKey) }
        
        var derivedHdKey = ptc_hd_key()
        ptc_hd_key_init(&derivedHdKey)
        defer { ptc_hd_key_destroy(&derivedHdKey) }
        
        let result = ptc_hd_key_derive(&hdKey, index, hardened, &derivedHdKey)
        guard result == PTC_SUCCESS,
            let derivedKey = derivedHdKey.hdPrivateKey() else {
                return nil
        }
        return derivedKey
    }
}

extension HDPrivateKey: ZeroOutable {
    public func zeroOut() {
        raw.zeroOut()
    }
}

extension Data {
    @inline(__always)
    func resized(minimumLength zeroCount: Int) -> Data {
        return count < zeroCount ? Data(count: zeroCount - count) + self : self
    }
}
