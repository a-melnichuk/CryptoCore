//
//  TRONPublicKey.swift
//  TRONCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public struct TRONPublicKey {
    public let raw: Data
    
    public init(raw: Data) {
        self.raw = raw
    }
}

extension TRONPublicKey: AnyPublicKey {
    public func address() -> String? {
        return TRONCore.address(publicKey: raw)
    }
}
