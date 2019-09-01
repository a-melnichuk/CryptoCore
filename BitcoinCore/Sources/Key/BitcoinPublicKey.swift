//
//  BitcoinPublicKey.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public struct BitcoinPublicKey {
    public let raw: Data
    public let network: Network
    public var segwit: Bool
    
    public init(raw: Data,
                network: Network,
                segwit: Bool) {
        self.network = network
        self.raw = raw
        self.segwit = segwit
    }
}

extension BitcoinPublicKey: AnyPublicKey {
    public func address() -> String? {
        if segwit {
            return BitcoinCore.segwitAddress(raw, network: network)
        }
        return BitcoinCore.address(publicKey: raw, network: network)
    }
}
