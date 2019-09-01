//
//  BitcoinPrivateKeyProtocol.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 9/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public enum BitcoinKeyKind {
    case raw(ZeroOuted<Data>)
    case hd(HDPrivateKey)
}

public protocol BitcoinPrivateKeyProtocol {
    var network: Network { get }
    var key: BitcoinKeyKind { get }
    var segwit: Bool { get set }
    
    init(key: BitcoinKeyKind, network: Network, segwit: Bool)
}

public extension BitcoinPrivateKeyProtocol where Self: AnyPrivateKey {
    var raw: Data {
        switch key {
        case .raw(let zeroOuted):
            return zeroOuted.value
        case .hd(let hd):
            return hd.raw
        }
    }
    
    init(hdKey: HDPrivateKey, network: Network, segwit: Bool) {
        self.init(key: .hd(hdKey), network: network, segwit: segwit)
    }
    
    init(raw: Data, network: Network, segwit: Bool) {
        var data = raw
        self.init(key: .raw(ZeroOuted(&data)), network: network, segwit: segwit)
    }
    
    init?(rawPrivateKey: String, network: Network, segwit: Bool) {
        guard let data = WIF.decode(rawPrivateKey,
                                    version: network.privatekey,
                                    compressed: network.hasCompressedWIFKeys) else {
                                        return nil
        }
        self.init(raw: data, network: network, segwit: segwit)
    }
    
    init?(seed: Seed, network: Network, segwit: Bool) {
        guard let hdPrivateKey = HDPrivateKey(seed: seed) else {
            return nil
        }
        self.init(hdKey: hdPrivateKey, network: network, segwit: segwit)
    }
    
    func rawPrivateKey() -> String? {
        return WIF.encode(raw, version: network.privatekey, compressed: network.hasCompressedWIFKeys)
    }
    
    func derivedPrivateKey(path: BIP32Path) -> Self? {
        switch key {
        case .raw:
            return self
        case .hd(let hdKey):
            guard let derived = hdKey.derived(for: path.description) else {
                return nil
            }
            return Self(hdKey: derived, network: network, segwit: segwit)
        }
    }
    
    func anyPublicKey() -> AnyPublicKey? {
        guard let publicKey = BitcoinCore.publicKey(privateKey: raw) else {
            return nil
        }
        return BitcoinPublicKey(raw: publicKey, network: network, segwit: segwit)
    }
    
    func anyDerivedPrivateKey(path: BIP32Path) -> AnyPrivateKey? {
        return derivedPrivateKey(path: path)
    }
}
