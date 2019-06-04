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
    struct Waves {
    }
}

public extension Crypto.Waves {
    
    static func publicKey(privateKey: Data) -> Data? {
        let count = Int(PTC_WAVES_PUBKEY_BYTE_COUNT)
        return Crypto.callCrypto(privateKey, outCount: count) { ptc_waves_public_key($0, $2) }
    }
    
    static func address(publicKey: Data, scheme: UInt8 = 87 /* "W" */) -> String? {
        let count = Int(PTC_WAVES_ADDRESS_BYTE_COUNT)
        let address = Crypto.callCrypto(publicKey, outCount: count) {
            ptc_waves_address($0, scheme, $2)
        }
        guard let addressBytes = address else {
            return nil
        }
        return Base58.encode(addressBytes)
    }
    
    static func valid(address: String, scheme: UInt8 = 87 /* "W" */) -> Bool {
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
    
    static func transferTransaction(senderPrivateKey: Data,
                                    recipientAddress: String,
                                    amount: Int64,
                                    fee: Int64,
                                    timeOffset: Int64,
                                    assetId: String? = nil,
                                    feeAssetId: String? = nil,
                                    attachment: Data? = nil) -> WavesTransferTransaction? {
        // convert arguments to C struct
        
        var createInfo = ptc_waves_transfer_tx_create_info()
        createInfo.sender_privkey = senderPrivateKey.withUnsafeBytes { UnsafeMutablePointer(mutating: $0) }
        createInfo.recipient_address = recipientAddress.withCString { UnsafeMutablePointer(mutating: $0) }
        createInfo.recipient_address_length = recipientAddress.count
        createInfo.amount_wavelets = amount
        createInfo.fee_wavelets = fee
        createInfo.time_offset = timeOffset
        createInfo.asset_id = assetId?.withCString { UnsafeMutablePointer(mutating: $0) }
        createInfo.asset_id_length = assetId?.count ?? 0
        createInfo.fee_asset_id = feeAssetId?.withCString { UnsafeMutablePointer(mutating: $0) }
        createInfo.fee_asset_id_length = feeAssetId?.count ?? 0
        createInfo.attachment = attachment?.withUnsafeBytes { UnsafeMutablePointer(mutating: $0) }
        // handle data longer than short
        let attachmentLenght = min(Int(Int16.max), attachment?.count ?? 0)
        createInfo.attachment_length = Int16(attachmentLenght)
        
        var tx = ptc_waves_transfer_tx();
        let result = ptc_waves_transfer_tx_init(&createInfo, &tx)
        defer { ptc_waves_make_transfer_tx_destroy(&tx) }
        guard result == PTC_SUCCESS else { return nil }
        let attachmentData: Data? = attachment == nil ? nil : Data(bytes: tx.attachment, count: tx.attachment_length)
        let id = String(cString: tx.id)
        let senderPublicKey = String(cString: tx.sender_public_key)
        let signature = String(cString: tx.signature)
        return WavesTransferTransaction(id: id,
                                        senderPublicKey: senderPublicKey,
                                        signature: signature,
                                        attachment: attachmentData,
                                        timestamp: tx.timestamp,
                                        recipientAddress: recipientAddress,
                                        amount: amount,
                                        fee: fee,
                                        assetId: assetId,
                                        feeAssetId: feeAssetId)
    }
    
    public static func testInt2() -> Int {
        return Crypto.testInt()
    }
    
    public static func testInt() -> Int {
        return Int(ptc_waves_test_int())
    }
    
    public static func testSha() -> String? {
        print("__SHA#1")
        let data = Crypto.data(fromHex: "6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77")!
        var out = Data(count: 32)
        let count = data.count
        let result: ptc_result = out.withUnsafeMutableBytes { outBuf in
            data.withUnsafeBytes { dataBuf in
                if let dataPtr = dataBuf.baseAddress,
                    let outPtr = outBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_waves_test_sha(dataPtr, count, outPtr)
                }
                return PTC_ERROR_GENERAL
            }
        }
        return result == PTC_SUCCESS ? Crypto.hex(fromData: out) : nil
    }
    
    public static func testSha2() -> String? {
        let data = Crypto.data(fromHex: "6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77")!
        guard let sha256 = Crypto.sha256(data) else {
            return nil
        }
        return Crypto.hex(fromData: sha256)
    }
    
    public static func testSha3() -> String? {
        let data = Crypto.data(fromHex: "6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77")!
        var out = Data(count: 32)
        let count = data.count
        let result: ptc_result = out.withUnsafeMutableBytes { outBuf in
            data.withUnsafeBytes { dataBuf in
                if let dataPtr = dataBuf.baseAddress,
                    let outPtr = outBuf.bindMemory(to: UInt8.self).baseAddress {
                    return ptc_sha256(dataPtr, count, outPtr)
                }
                return PTC_ERROR_GENERAL
            }
        }
        return result == PTC_SUCCESS ? Crypto.hex(fromData: out) : nil
    }
    
    public static func test() {
        print("_TEST_INT: \(ptc_waves_test_int())");
        ptc_waves_test_print()
    }
}
