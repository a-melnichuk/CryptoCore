//
//  Networks.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 9/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import BitcoinCore

struct Zencash: Network {
    let coin: UInt = 121
    let privatekey: [UInt8] = [0x80]
    let pubkeyhash: [UInt8] = [32, 137]
    let scripthash: [UInt8] = [32, 150]
    let transactionVersion: Int32 = 12
    let hasStaticFees: Bool = true
    
    init() {}
    
    func buildP2PKHScript(pubKeyHash: Data, blockInfo: BlockInfo) -> Data? {
        return Script.buildZencashP2PKHScript(pubKeyHash: pubKeyHash, blockInfo: blockInfo)
    }
    
    func buildP2WPKHScript(pubKeyHash: Data, blockInfo: BlockInfo) -> Data? {
        return Script.buildZencashP2WPKHScript(pubKeyHash: pubKeyHash, blockInfo: blockInfo)
    }
}

struct Dash: Network {
    let coin: UInt = 5
    let pubkeyhash: [UInt8] = [0x4c]
    let privatekey: [UInt8] = [0xcc]
    let scripthash: [UInt8] = [0x05]
    let xpubkey: UInt32 = 0x0488b21e
    let xprivkey: UInt32 = 0x0488ade4
    let magic: UInt32 = 0xf9beb4d9
    
    init() {}
}

struct Litecoin: Network {
    let coin: UInt = 2
    let pubkeyhash: [UInt8] = [0x30]
    let privatekey: [UInt8] = [0xb0]
    let scripthash: [UInt8] = [0x32]
    let xpubkey: UInt32 = 0x0488b21e
    let xprivkey: UInt32 = 0x0488ade4
    let magic: UInt32 = 0xf9beb4d9
    
    init() {}
}


