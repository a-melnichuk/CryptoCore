//
//  WavesTransaction.swift
//  WavesCore
//
//  Created by Alex Melnichuk on 6/4/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import paytomat_waves_core

public extension WavesCore {
    struct Transaction {
        public enum Kind: UInt8 {
            case transfer = 4
        }
        private init() {}
    }
    
    enum TransactionError: Error {
        case invalidAmount
        case invalidFee
        case invalidBalance
        case amountExceedsBalance
        case cannotSendToSelf
        case transactionIdGenerationFailed
        case publicKeyGenerationFailed
        case addressDecodingFailed
        case assetIdDecodingFailed
        case feeAssetIdDecodingFailed
        case signatureFailed
    }
}

public extension WavesCore.Transaction {
    struct Transfer {
        public enum AssetFlag: UInt8 {
            case waves = 0
            case asset = 1
        }
        
        public struct Signed {
            public let id: String
            public let senderPublicKey: String
            public let signature: String
            public let attachment: Data?
            public let timestamp: Int64
            public let recipient: String
            public let amount: Int64
            public let fee: Int64
            public let assetId: String?
            public let feeAssetId: String?
        }
        
        public let recipient: String
        public let amount: Int64
        public let fee: Int64
        public let assetId: String?
        public let feeAssetId: String?
        public let attachment: Data?
        public let timeOffset: Int64
        public let scheme: UInt8 // W
        public let balance: Int64?
        
        public init(recipient: String,
                    amount: Int64,
                    fee: Int64,
                    assetId: String?,
                    feeAssetId: String?,
                    attachment: Data?,
                    timeOffset: Int64,
                    scheme: UInt8 = 87,
                    balance: Int64? = nil) {
            self.recipient = recipient
            self.amount = amount
            self.fee = fee
            self.assetId = assetId
            self.feeAssetId = feeAssetId
            self.attachment = attachment
            self.timeOffset = timeOffset
            self.scheme = scheme
            self.balance = balance
        }
    }
}

public extension WavesCore.Transaction.Transfer {
    func sign(privateKey: inout Data) throws -> Signed {
        guard let publicKeyBytes = WavesCore.publicKey(privateKey: privateKey),
            let publicKey = Base58.encode(publicKeyBytes) else {
            throw WavesCore.TransactionError.publicKeyGenerationFailed
        }
        guard let recipient = Base58.decode(self.recipient) else {
            throw WavesCore.TransactionError.addressDecodingFailed
        }
        if let sender = WavesCore.address(publicKey: publicKeyBytes, scheme: scheme) {
            guard sender != self.recipient else {
                throw WavesCore.TransactionError.cannotSendToSelf
            }
        }
        
        var amount = self.amount
        guard amount > 0 else {
            throw WavesCore.TransactionError.invalidAmount
        }
        guard fee > 0 else {
            throw WavesCore.TransactionError.invalidFee
        }
        if let balance = self.balance, amount == balance {
            guard balance > 0 else {
                throw WavesCore.TransactionError.invalidBalance
            }
            guard fee < amount else {
                throw WavesCore.TransactionError.amountExceedsBalance
            }
            amount -= fee
        }
        
        let type = WavesCore.Transaction.Kind.transfer
        let dateMillis = Int64((Date().timeIntervalSince1970 * 1000.0).rounded())
        let timestamp = dateMillis + timeOffset
        let attachmentLength = Int16(truncatingIfNeeded: attachment?.count ?? 0)
        
        let assetIdData: Data
        let assetIdFlag: AssetFlag
        let feeAssetIdData: Data
        let feeAssetIdFlag: AssetFlag
        let attachmentData: Data
        
        if let assetId = assetId, !assetId.isEmpty {
            guard let decodedAssetId = Base58.decode(assetId) else {
                throw WavesCore.TransactionError.assetIdDecodingFailed
            }
            assetIdData = decodedAssetId
            assetIdFlag = .asset
        } else {
            assetIdData = Data()
            assetIdFlag = .waves
        }
        
        if let feeAssetId = feeAssetId, !feeAssetId.isEmpty {
            guard let decodedFeeAssetId = Base58.decode(feeAssetId) else {
                throw WavesCore.TransactionError.feeAssetIdDecodingFailed
            }
            feeAssetIdData = decodedFeeAssetId
            feeAssetIdFlag = .asset
        } else {
            feeAssetIdData = Data()
            feeAssetIdFlag = .waves
        }
        
        if let attachment = attachment, !attachment.isEmpty {
            attachmentData = attachment
        } else {
            attachmentData = Data()
        }
        
        var serializedTx = Data()
        serializedTx.append(Data(loadBytes: type.rawValue))
        serializedTx.append(publicKeyBytes)
        serializedTx.append(assetIdFlag.rawValue)
        serializedTx.append(assetIdData)
        serializedTx.append(feeAssetIdFlag.rawValue)
        serializedTx.append(feeAssetIdData)
        serializedTx.append(Data(loadBytes: timestamp.bigEndian))
        serializedTx.append(Data(loadBytes: amount.bigEndian))
        serializedTx.append(Data(loadBytes: fee.bigEndian))
        serializedTx.append(recipient)
        serializedTx.append(Data(loadBytes: attachmentLength.bigEndian))
        serializedTx.append(attachmentData)
        
        guard let signatureBytes = WavesCore.sign(serializedTx, privateKey: &privateKey),
            let signature = Base58.encode(signatureBytes) else {
            throw WavesCore.TransactionError.signatureFailed
        }
        
        guard let idBytes = Crypto.blake2b256(serializedTx),
            let id = Base58.encode(idBytes) else {
            throw WavesCore.TransactionError.transactionIdGenerationFailed
        }
        
        return Signed(id: id,
                      senderPublicKey: publicKey,
                      signature: signature,
                      attachment: attachment,
                      timestamp: timestamp,
                      recipient: self.recipient,
                      amount: self.amount,
                      fee: self.fee,
                      assetId: self.assetId,
                      feeAssetId: self.feeAssetId)
    }
}

extension WavesCore.Transaction.Transfer.Signed: Encodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case senderPublicKey
        case signature
        case attachment
        case timestamp
        case recipient
        case amount
        case fee
        case assetId
        case feeAssetId
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(senderPublicKey, forKey: .senderPublicKey)
        try container.encode(signature, forKey: .signature)
        if let attachment = attachment {
            try container.encode(Crypto.hex(fromData: attachment), forKey: .attachment)
        }
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(recipient, forKey: .recipient)
        try container.encode(amount, forKey: .amount)
        try container.encode(fee, forKey: .fee)
        try container.encodeIfPresent(assetId, forKey: .assetId)
        try container.encodeIfPresent(feeAssetId, forKey: .feeAssetId)
    }
}
