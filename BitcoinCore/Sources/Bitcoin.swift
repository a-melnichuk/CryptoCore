//
//  Bitcoin.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 8/29/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public struct Bitcoin: Network {
    // transaction size with 3 inputs and 2 outputs was used
    public static let averageTransactionSizeInBytes = 521
    
    public let coin: UInt = 0
    public let pubkeyhash: [UInt8] = [0x00]
    public let privatekey: [UInt8] = [0x80]
    public let scripthash: [UInt8] = [0x05]
    public let xpubkey: UInt32 = 0x0488b21e
    public let xprivkey: UInt32 = 0x0488ade4
    public let magic: UInt32 = 0xf9beb4d9
    
    public init() {}
}
