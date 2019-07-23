//
//  EthereumPrivateKey.swift
//  EthereumCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public class EthereumPrivateKey {
    
    private let hdKey: HDPrivateKey
    
    public init(hdKey: HDPrivateKey) {
        self.hdKey = hdKey
    }
    
    required public convenience init?(seed: Seed) {
        guard let hdPrivateKey = HDPrivateKey(seed: seed) else {
            return nil
        }
        self.init(hdKey: hdPrivateKey)
    }
}

extension EthereumPrivateKey: AnyPrivateKey {
    public var raw: Data {
        return hdKey.raw
    }
    
    public func anyDerivedPrivateKey(path: BIP32Path) -> AnyPrivateKey? {
        guard let derived = hdKey.derived(for: path.description) else {
            return nil
        }
        return EthereumPrivateKey(hdKey: derived)
    }
    
    public func anyPublicKey() -> AnyPublicKey? {
        guard let publicKey = EthereumCore.publicKey(privateKey: hdKey.raw) else {
            return nil
        }
        return EthereumPublicKey(raw: publicKey)
    }
}
