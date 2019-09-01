//
//  Crypto+Bitcoin.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import paytomat_btc_core
import paytomat_crypto_core
import secp256k1

public extension Crypto {
    typealias Bitcoin = BitcoinCore
}

public struct BitcoinCore {
    
    public static func hash160(_ data: Data) -> Data? {
        return Crypto.sha256ripemd160(data)
    }
    
    public static func hash160(network: Network, address: String) -> Data? {
        guard let decoded = Base58.decode(address) else {
            return nil
        }
        let headerWidth = network.pubkeyhash.count
        return decoded.dropFirst(headerWidth).dropLast(4)
    }
    
    public static func publicKey(privateKey: Data, compressed: Bool = true) -> Data? {
        let count = compressed ? PTC_PUBLIC_KEY_COMPRESSED : PTC_PUBLIC_KEY_UNCOMPRESSED
        var publicKey = Data(count: Int(count))
        let result: ptc_result = publicKey.withUnsafeMutableBytes { publicKeyBuf in
            privateKey.withUnsafeBytes { privateKeyBuf in
                if let privateKeyPtr = privateKeyBuf.bindMemory(to: UInt8.self).baseAddress,
                    let publicKeyPtr = publicKeyBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_create_public_key(privateKeyPtr, Int32(privateKeyBuf.count), compressed, publicKeyPtr)
                }
                return PTC_ERROR_GENERAL
            }
        }
        return result == PTC_SUCCESS ? publicKey : nil
    }
    
    public static func address(publicKey: Data, network: Network) -> String? {
        guard let hash160 = Crypto.sha256ripemd160(publicKey) else {
            return nil
        }
        return Base58Check.encode(hash160, version: network.pubkeyhash)
    }
    
    public static func segwitAddress(_ data: Data, network: Network) -> String? {
        return Base58Check.encode(data, version: network.scripthash)
    }
    
    public static func isSegwitAddress(_ address: String, network: Network) -> Bool {
        guard network.supportsSegwitAddresses else {
            return false
        }
        return Base58Check.valid(address, version: network.scripthash)
    }
    
    public static func sign(_ data: Data, privateKeyBytes: Data) -> Data? {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }
        
        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate() }
        
        var status: Int32 = data.withUnsafeBytes { dataBuf in
            privateKeyBytes.withUnsafeBytes { privateKeyBuf in
                if let dataPtr = dataBuf.bindMemory(to: UInt8.self).baseAddress,
                    let privateKeyPtr = privateKeyBuf.bindMemory(to: UInt8.self).baseAddress {
                        return secp256k1_ecdsa_sign(ctx, signature, dataPtr, privateKeyPtr, nil, nil)
                }
                return 0
            }
        }
        guard status == 1 else {
            return nil
        }
        
        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { normalizedsig.deallocate() }
        
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)
        
        var length: size_t = 128
        var der = Data(count: length)
        status = der.withUnsafeMutableBytes { derBuf in
            if let derPtr = derBuf.bindMemory(to: UInt8.self).baseAddress {
                return secp256k1_ecdsa_signature_serialize_der(ctx, derPtr, &length, normalizedsig)
            }
            return 0
        }
        guard status == 1 else {
            return nil
        }
        der.count = length
        return der
    }
}
