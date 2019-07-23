//
//  BIP32Path.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public struct BIP32Path {
    public enum Purpose: Int {
        case m44 = 44
        case m49 = 49
    }
    
    public enum Change: Int {
        case external = 0
        case change = 1
    }
    
    public let purpose: Purpose
    public let coin: UInt
    public let account: UInt // index of account
    public let change: Change
    public let addressIndex: UInt
    
    public init(purpose: Purpose = .m44,
                coin: UInt,
                account: UInt = 0,
                change: Change = .external,
                addressIndex: UInt = 0) {
        self.purpose = purpose
        self.coin = coin
        self.account = account
        self.change = change
        self.addressIndex = addressIndex
    }
}

extension BIP32Path: CustomStringConvertible {
    public var description: String {
        return "m/\(purpose.rawValue)'/\(coin)'/\(account)'/\(change.rawValue)/\(addressIndex)"
    }
}
