//
//  Crypto+WavesTransaction.swift
//  WavesCore
//
//  Created by Alex Melnichuk on 6/4/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public extension Crypto.Waves {
    struct TransferTransaction {
        public struct Signed {
            let id: String
            let senderPublicKey: String
            let signature: String
            let attachment: Data?
            let timestamp: Int64
            let recipient: String
            let amount: Int64
            let fee: Int64
            let assetId: String?
            let feeAssetId: String?
        }
        
        public let recipient: String
        public let amount: Int64
        public let fee: Int64
        public let assetId: String?
        public let feeAssetId: String?
        public let attachment: Data?
        
        public init(recipient: String,
                    amount: Int64,
                    fee: Int64,
                    assetId: String?,
                    feeAssetId: String?,
                    attachment: Data?) {
            self.recipient = recipient
            self.amount = amount
            self.fee = fee
            self.assetId = assetId
            self.feeAssetId = feeAssetId
            self.attachment = attachment
        }
    }
    
    enum TransactionError {
        
    }
}

public extension Crypto.Waves.TransferTransaction {
    func sign(privateKey: inout Data) throws -> Signed {
        var data = Data()
        data.app
    }
}

extension Crypto.Waves.TransferTransaction.Signed: Encodable {
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
        try container.encode(assetId, forKey: .assetId)
        try container.encode(feeAssetId, forKey: .feeAssetId)
    }
}
