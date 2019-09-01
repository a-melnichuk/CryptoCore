//
//  Script.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 8/29/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public struct Script {
    public static let OP_DUP: UInt8 = 0x76
    public static let OP_HASH160: UInt8 = 0xa9
    public static let OP_0: UInt8 = 0x14
    public static let OP_EQUAL: UInt8 = 0x87
    public static let OP_EQUALVERIFY: UInt8 = 0x88
    public static let OP_CHECKSIG: UInt8 = 0xac
    public static let OP_CODESEPARATOR: UInt8 = 0xab
    public static let OP_CHECKBLOCKATHEIGHT: UInt8 = 0xb4
    public static let OP_PUSHDATA1: UInt8 = 0x4c
    public static let OP_PUSHDATA2: UInt8 = 0x4d
    public static let OP_PUSHDATA4: UInt8 = 0x4e
}

public extension Script {
    // Standard Transaction to Bitcoin address (pay-to-pubkey-hash)
    // scriptPubKey: OP_DUP OP_HASH160 OP_0 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
    static func buildP2PKHScript(pubKeyHash: Data) -> Data {
        var data = Data()
        data.append(OP_DUP)
        data.append(OP_HASH160)
        data.append(OP_0)
        data.append(pubKeyHash)
        data.append(OP_EQUALVERIFY)
        data.append(OP_CHECKSIG)
        return data
    }
    
    static func buildP2WPKHScript(pubKeyHash: Data) -> Data {
        var data = Data()
        data.append(OP_HASH160)
        data.append(UInt8(pubKeyHash.count))
        data.append(pubKeyHash)
        data.append(OP_EQUAL)
        return data
    }
    
    static func segwitScriptSig(hash160: Data) -> Data {
        var data = Data(count: 1)
        data.append(OP_0)
        data.append(hash160)
        return data
    }
    
    static func isPublicKeyHashOut(_ script: Data) -> Bool {
        return script.count == 25
            && script[0] == OP_DUP
            && script[1] == OP_HASH160
            && script[2] == OP_0
            && script[23] == OP_EQUALVERIFY
            && script[24] == OP_CHECKSIG
    }
    
    static func getPublicKeyHash(from script: Data) -> Data {
        return script[3..<23]
    }
}


// MARK: Script + Zencash

public extension Script {
    
    static func buildZencashP2PKHScript(pubKeyHash: Data, blockInfo: BlockInfo) -> Data {
        var data = Data()
        data.append(OP_DUP)
        data.append(OP_HASH160)
        data.append(push(data: pubKeyHash))
        data.append(OP_EQUALVERIFY)
        data.append(OP_CHECKSIG)
        data.append(push(data: serialize(blockHash: blockInfo.blockHash)))
        data.append(push(data: serialize(blockIndex: blockInfo.blockIndex)))
        data.append(OP_CHECKBLOCKATHEIGHT)
        return data
    }
    
    static func buildZencashP2WPKHScript(pubKeyHash: Data, blockInfo: BlockInfo) -> Data {
        var data = Data()
        data.append(OP_HASH160)
        data.append(push(data: pubKeyHash))
        data.append(OP_EQUAL)
        data.append(push(data: serialize(blockHash: blockInfo.blockHash)))
        data.append(push(data: serialize(blockIndex: blockInfo.blockIndex)))
        data.append(OP_CHECKBLOCKATHEIGHT)
        return data
    }
    
    private static func serialize(blockHash: Data) -> Data {
        var data = blockHash
        data.reverse()
        return data
    }
    
    private static func serialize(blockIndex: Int32) -> Data {
        var bytes = Data(loadBytes: blockIndex)
        if bytes[3] == 0 {
            bytes = Data(bytes.dropLast())
        }
        return Data(bytes)
    }
    
    private static func push(data: Data) -> Data {
        var pushed = Data()
        if data.count < Int(OP_PUSHDATA1) {
            pushed.append(UInt8(data.count).littleEndian)
            pushed.append(data)
        } else if data.count < 0xff {
            pushed.append(OP_PUSHDATA1)
            pushed.append(UInt8(data.count).littleEndian)
            pushed.append(data)
        } else if data.count < 0xffff {
            pushed.append(OP_PUSHDATA2)
            pushed.append(Data(loadBytes: UInt16(data.count).littleEndian))
            pushed.append(data)
        } else {
            pushed.append(OP_PUSHDATA4)
            pushed.append(Data(loadBytes: UInt32(data.count).littleEndian))
            pushed.append(data)
        }
        return pushed
    }
}

