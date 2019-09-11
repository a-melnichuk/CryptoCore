//
//  TRONPrivateKey.swift
//  TRONCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public class TRONPrivateKey {
    
    private enum KeyKind {
        case raw(ZeroOuted<Data>)
        case hd(HDPrivateKey)
    }
    
    private let key: KeyKind
    
    public init(hdKey: HDPrivateKey) {
        self.key = .hd(hdKey)
    }
    
    public required init?(rawPrivateKey: String) {
        guard var data = Hex.decode(rawPrivateKey), data.count >= 32 else {
            return nil
        }
        defer { data.zeroOut() }
        self.key = .raw(ZeroOuted(&data))
    }
    
    required public convenience init?(seed: Seed) {
        guard let hdPrivateKey = HDPrivateKey(seed: seed) else {
            return nil
        }
        self.init(hdKey: hdPrivateKey)
    }
}

extension TRONPrivateKey: AnyPrivateKey {
    public var raw: Data {
        switch key {
        case .raw(let zeroOuted):
            return zeroOuted.value
        case .hd(let hd):
            return hd.raw
        }
    }
    
    public func anyDerivedPrivateKey(path: BIP32Path) -> AnyPrivateKey? {
        switch key {
        case .raw:
            return self
        case .hd(let hdKey):
            guard let derived = hdKey.derived(for: path.description) else {
                return nil
            }
            return TRONPrivateKey(hdKey: derived)
        }
    }
    
    public func rawPrivateKey() -> String? {
        return Hex.encode(raw)
    }
    
    public func anyPublicKey() -> AnyPublicKey? {
//        guard let publicKey = TRONCore.publicKey(privateKey: raw) else {
//            return nil
//        }
//        return TRONPublicKey(raw: publicKey)
        return nil
    }
}
