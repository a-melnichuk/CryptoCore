//
//  Crypto+Waves.swift
//  WavesCore
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import paytomat_waves_core
import paytomat_crypto_core

public extension Crypto {
    typealias Waves = WavesCore
}

public struct WavesCore {
    static func publicKey(privateKey: Data) -> Data? {
        let count = Int(PTC_WAVES_PUBKEY_BYTE_COUNT)
        return Crypto.callCrypto(privateKey, outCount: count) { ptc_waves_public_key($0, $2) }
    }
    
    static func address(publicKey: Data, scheme: UInt8 = 87 /* W */) -> String? {
        let count = Int(PTC_WAVES_ADDRESS_BYTE_COUNT)
        let address = Crypto.callCrypto(publicKey, outCount: count) {
            ptc_waves_address($0, scheme, $2)
        }
        guard let addressBytes = address else {
            return nil
        }
        return Base58.encode(addressBytes)
    }
    
    static func valid(address: String, scheme: UInt8 = 87 /* W */) -> Bool {
        let result = address.withCString { ptc_waves_address_valid($0, scheme) }
        return result == PTC_SUCCESS
    }
    
    static func secureHash(_ data: Data) -> Data? {
        let count = Int(PTC_WAVES_SECURE_HASH_BYTE_COUNT)
        return Crypto.callCrypto(data, outCount: count) { ptc_waves_secure_hash($0, $1, $2) }
    }
    
    static func sign(_ data: Data, privateKey: inout Data) -> Data? {
        var signature = Data(count: Int(PTC_WAVES_SIGNATURE_BYTE_COUNT))
        let count = data.count
        let result: ptc_result = signature.withUnsafeMutableBytes { signatureBuf in
            data.withUnsafeBytes { dataBuf in
                privateKey.withUnsafeBytes { privateKeyBuf in
                    if let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress,
                        let privateKeyPtr = privateKeyBuf.bindMemory(to: UInt8.self).baseAddress,
                        let signaturePtr = signatureBuf.bindMemory(to: UInt8.self).baseAddress {
                        return ptc_waves_sign(privateKeyPtr, dataPtr, count, signaturePtr)
                    }
                    return PTC_ERROR_GENERAL
                }
            }
        }
        return result == PTC_SUCCESS ? signature : nil
    }
}
