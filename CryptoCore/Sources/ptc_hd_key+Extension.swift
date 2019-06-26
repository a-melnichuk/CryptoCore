//
//  ptc_hd_key+Extension.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/26/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

extension ptc_hd_key {
    init?(privateKey: HDPrivateKey) {
        guard let publicKey = privateKey.publicKey() else {
            return nil
        }
        var hdKey = ptc_hd_key()
        let success: Bool = privateKey.raw.withUnsafeBytes { privateKeyBuf in
            return publicKey.raw.withUnsafeBytes { publicKeyBuf in
                return privateKey.chainCode.withUnsafeBytes { chainCodeBuf in
                    guard let privateKeyPtr = privateKeyBuf.bindMemory(to: UInt8.self).baseAddress,
                        let publicKeyPtr = publicKeyBuf.bindMemory(to: UInt8.self).baseAddress,
                        let chainCodePtr = chainCodeBuf.bindMemory(to: UInt8.self).baseAddress else {
                            return false
                    }
                    return ptc_hd_key_create(&hdKey,
                                             privateKeyPtr,
                                             privateKey.raw.count,
                                             publicKeyPtr,
                                             publicKey.raw.count,
                                             chainCodePtr,
                                             privateKey.depth,
                                             privateKey.fingerprint,
                                             privateKey.childIndex)
                    
                }
            }
        }
        
        guard success else {
            return nil
        }
        self = hdKey
    }
    
    mutating func hdPrivateKey() -> HDPrivateKey? {
        let privateKey = Data(bytes: private_key.data, count: private_key.length)
        let chainCodeSize = MemoryLayout.size(ofValue: chain_code)
        let chainCodeBuf = UnsafeBufferPointer(start: &chain_code.0, count: chainCodeSize)
        let chainCode = Data(buffer: chainCodeBuf)
        return HDPrivateKey(privateKey: privateKey,
                            chainCode: chainCode,
                            depth: depth,
                            fingerprint: fingerprint,
                            childIndex: child_index)
    }
}
