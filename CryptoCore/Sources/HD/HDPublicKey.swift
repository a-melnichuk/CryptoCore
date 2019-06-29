//
//  HDPublicKey.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/24/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public struct HDPublicKey {
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32
    public let raw: Data
    public let chainCode: Data
    
    public init?(privateKey: HDPrivateKey,
                 compressed: Bool = true,
                 chainCode: Data? = nil,
                 depth: UInt8 = 0,
                 fingerprint: UInt32 = 0,
                 childIndex: UInt32 = 0) {
        guard let raw = Crypto.Key.publicKey(from: privateKey.raw, compressed: compressed) else {
            return nil
        }
        self.init(raw: raw,
                  chainCode: chainCode ?? privateKey.chainCode,
                  depth: depth,
                  fingerprint: fingerprint,
                  childIndex: childIndex)
    }
    
    public init(raw: Data,
                chainCode: Data,
                depth: UInt8,
                fingerprint: UInt32,
                childIndex: UInt32) {
        self.raw = raw
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }
}
