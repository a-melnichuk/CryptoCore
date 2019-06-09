//
//  Crypto+Waves.swift
//  NEMCore
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import paytomat_nem_core
import paytomat_crypto_core

public extension Crypto {
    typealias NEM = NEMCore
}

public struct NEMCore {
    
    public static let mainnetNetworkByte: UInt8 = 0x68
    
    public static func publicKey(privateKey: Data) -> Data? {
        let count = Int(PTC_NEM_PUBKEY_BYTE_COUNT)
        return Crypto.callCrypto(privateKey, outCount: count) { ptc_nem_public_key($0, $2) }
    }
    
    public static func address(publicKey: Data, networkByte: UInt8 = NEMCore.mainnetNetworkByte) -> String? {
        let count = Int(PTC_NEM_ADDRESS_ENCODED_CHAR_COUNT)
        let result = Crypto.callCrypto(publicKey, outCount: count) {
            ptc_nem_address($0, networkByte, $2)
        }
        guard let address = result,
            let string = String(data: address, encoding: .ascii) else {
                return nil
        }
        return string
    }
    
    public static func valid(address: String, networkByte: UInt8 = NEMCore.mainnetNetworkByte) -> Bool {
        let address = denormalize(address: address)
        guard let decoded = Base32.decode(address) else {
            return false
        }
        let decodedPrefix = Data(decoded.prefix(21))
        guard let checksum = Crypto.sha3_256(decodedPrefix) else {
            return false
        }
        return checksum.prefix(4) == decoded.suffix(4)
//        guard let addressBytes = address.cString(using: .ascii) else {
//            return false
//        }
//        let valid: Bool = addressBytes.withUnsafeBufferPointer { addressBuf in
//            if let addressPtr = addressBuf.baseAddress {
//                return ptc_nem_address_valid(addressPtr, networkByte)
//            }
//            return false
//        }
//        return valid
    }
    
    public static func denormalize(address: String) -> String {
        let address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let addressBytes = address.cString(using: .ascii),
            !addressBytes.isEmpty else {
                return address
        }
        var size: size_t = 0
        
        addressBytes.withUnsafeBufferPointer {
            if let baseAddress = $0.baseAddress {
                ptc_nem_address_denormalize(baseAddress, &size, nil)
            }
        }
        
        var data = Data(count: size)
        let result: Bool = data.withUnsafeMutableBytes { dataBuf in
            addressBytes.withUnsafeBufferPointer { addressBuf in
                if let dataPtr = dataBuf.bindMemory(to: Int8.self).baseAddress,
                    let addressPtr = addressBuf.baseAddress {
                        ptc_nem_address_denormalize(addressPtr, &size, dataPtr)
                        return true
                }
                return false
            }
        }
        guard result else {
            return address
        }
        return String(data: data, encoding: .ascii) ?? address
    }
    
    public static func normalize(address: String) -> String {
        let address = denormalize(address: address)
        let dashCount = address.count / 6
        var data = Data(count: address.count + dashCount)
        let result: Bool = data.withUnsafeMutableBytes { dataBuf in
            if let dataPtr = dataBuf.bindMemory(to: Int8.self).baseAddress {
                address.withCString {
                    ptc_nem_address_normalize($0, dataPtr)
                }
                return true
            }
            return false
        }
        guard result else {
            return address
        }
        return String(data: data, encoding: .ascii) ?? address
    }
    
    public static func sign(_ data: Data, privateKey: inout Data) -> Data? {
        var signature = Data(count: Int(PTC_NEM_SIGNATURE_BYTE_COUNT))
        let count = data.count
        let result: ptc_result = signature.withUnsafeMutableBytes { signatureBuf in
            data.withUnsafeBytes { dataBuf in
                privateKey.withUnsafeBytes { privateKeyBuf in
                    if let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress,
                        let privateKeyPtr = privateKeyBuf.bindMemory(to: UInt8.self).baseAddress,
                        let signaturePtr = signatureBuf.bindMemory(to: UInt8.self).baseAddress {
                        return ptc_nem_sign(privateKeyPtr, dataPtr, count, signaturePtr)
                    }
                    return PTC_ERROR_GENERAL
                }
            }
        }
        return result == PTC_SUCCESS ? signature : nil
    }
}
