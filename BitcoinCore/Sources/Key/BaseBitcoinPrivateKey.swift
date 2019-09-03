//
//  BaseBitcoinPrivateKey.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

open class BaseBitcoinPrivateKey: BitcoinPrivateKeyProtocol {
    public let network: Network
    public var segwit: Bool
    public let key: BitcoinKeyKind
   
    public required init(key: BitcoinKeyKind, network: Network, segwit: Bool) {
        self.network = network
        self.key = key
        self.segwit = segwit
    }
}
