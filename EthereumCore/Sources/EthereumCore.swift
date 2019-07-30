//
//  Crypto+Ethereum.swift
//  EthereumCore
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import paytomat_eth_core
import paytomat_crypto_core
import struct BigInt.BigUInt


public extension Crypto {
    typealias Ethereum = EthereumCore
}

public struct EthereumCore {
    
    public struct GasCosts {
        public static let addingToNumbers: UInt = 3
        public static let calculatingHash: UInt = 30
        public static let transaction: UInt = 21000
        public static let tokenTransaction: UInt = 200000
    }
    
    public static let prefix = "0x"
    
    public static let frontierChainId = NetworkId.mainnet
    
    public static func publicKey(privateKey: Data) -> Data? {
        let count = Int(PTC_ETHEREUM_ECDSA_SERIALIZED_PUBKEY_BYTE_COUNT)
        return Crypto.callCrypto(privateKey, outCount: count) { ptc_eth_public_key($0, $1, $2) }
    }
    
    public static func address(publicKey: Data) -> String? {
        let addressBytes = Int(PTC_ETHEREUM_ADDRESS_CHARACTER_COUNT + 1)
        var addressPtr = UnsafeMutablePointer<CChar>.allocate(capacity: addressBytes)
        addressPtr.initialize(to: 0)
        defer { addressPtr.deallocate() }
        let result: ptc_result = publicKey.withUnsafeBytes { publicKeyBuf in
            if let publicKeyPtr = publicKeyBuf.bindMemory(to: UInt8.self).baseAddress {
                return ptc_eth_address(publicKeyPtr, publicKeyBuf.count, addressPtr)
            }
            return PTC_ERROR_GENERAL
        }
        return result == PTC_SUCCESS ? String(cString: addressPtr) : nil
    }
}
