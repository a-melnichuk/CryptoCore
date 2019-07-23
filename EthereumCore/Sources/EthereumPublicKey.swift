//
//  EthereumPublicKey.swift
//  EthereumCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public struct EthereumPublicKey {
    public let raw: Data
    
    public init(raw: Data) {
        self.raw = raw
    }
}

extension EthereumPublicKey: AnyPublicKey {
    public func address() -> String? {
        return EthereumCore.address(publicKey: raw)
    }
}
