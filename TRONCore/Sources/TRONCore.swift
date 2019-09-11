//
//  Crypto+TRON.swift
//  TRONCore
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import paytomat_trx_core
import paytomat_crypto_core
import struct BigInt.BigUInt


public extension Crypto {
    typealias TRON = TRONCore
}

public struct TRONCore {
    
    public static var pubkeyhash: [UInt8] {
        return [0x41]
    }
    
    public var privatekey: [UInt8] {
        return [0x80]
    }
    
//    public static func publicKey(privateKey: Data) -> Data? {
//        let count = Int(PTC_ETHEREUM_ECDSA_SERIALIZED_PUBKEY_BYTE_COUNT)
//        return Crypto.callCrypto(privateKey, outCount: count) { ptc_eth_public_key($0, $1, $2) }
//    }
    
    public static func address(publicKey: Data) -> String? {
        var publicKey = publicKey
        if publicKey.count == 65 {
            publicKey = publicKey.dropFirst()
        }
        guard let sha3_256 = Crypto.keccak256(publicKey)?.suffix(20),
            sha3_256.count == 20 else {
                return nil
        }
        return Base58Check.encode(sha3_256, version: TRONCore.pubkeyhash)
    }
    
}
