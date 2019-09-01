//
//  Network.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 8/29/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public protocol Network {
    var coin: UInt { get }
    var pubkeyhash: [UInt8] { get }
    var privatekey: [UInt8] { get }
    var scripthash: [UInt8] { get }
    
    var xpubkey: UInt32 { get }
    var xprivkey: UInt32 { get }
    var magic: UInt32 { get }
    
    var transactionVersion: Int32 { get }
    var supportsSegwitAddresses: Bool { get }
    var hasCompressedWIFKeys: Bool { get }
    var hasStaticFees: Bool { get }
    
    func buildP2PKHScript(pubKeyHash: Data, blockInfo: BlockInfo) -> Data?
    func buildP2WPKHScript(pubKeyHash: Data, blockInfo: BlockInfo) -> Data?
}

// MARK: Network+Extension

public extension Network {
    
    var pubkeyhash: [UInt8] {
        return [0]
    }
    
    var privatekey: [UInt8] {
        return [0]
    }
    
    var scripthash: [UInt8] {
        return [0]
    }
    
    var xpubkey: UInt32 {
        return 0
    }
    
    var xprivkey: UInt32 {
        return 0
    }
    
    var magic: UInt32 {
        return 0
    }
    
    var transactionVersion: Int32 {
        return 1
    }
    
    var supportsSegwitAddresses: Bool {
        return false
    }
    
    var hasCompressedWIFKeys: Bool {
        return true
    }
    
    var hasStaticFees: Bool {
        return false
    }
    
    func buildP2PKHScript(pubKeyHash: Data, blockInfo: BlockInfo) -> Data? {
        return Script.buildP2PKHScript(pubKeyHash: pubKeyHash)
    }
    
    func buildP2WPKHScript(pubKeyHash: Data, blockInfo: BlockInfo) -> Data? {
        return Script.buildP2WPKHScript(pubKeyHash: pubKeyHash)
    }
}
