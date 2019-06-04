//
//  WavesTransferTransaction.swift
//  WavesCore
//
//  Created by Alex Melnichuk on 6/4/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public struct WavesTransferTransaction {
    
    struct Keys {
        static let id = "id"
        static let senderPublicKey = "senderPublicKey"
        static let signature = "signature"
        static let attachment = "attachment"
        static let timestamp = "timestamp"
        static let recipient = "recipient"
        static let amount = "amount"
        static let fee = "fee"
        static let assetId = "assetId"
        static let feeAssetId = "feeAssetId"
    }
    
    // parsed from pcm
    let id: String
    let senderPublicKey: String
    let signature: String
    let attachment: Data?
    let timestamp: Int64
    // local
    let recipient: String
    let amount: Int64
    let fee: Int64
    let assetId: String?
    let feeAssetId: String?
    
    public init?(id: String?,
          senderPublicKey: String?,
          signature: String?,
          attachment: Data?,
          timestamp: Int64?,
          recipientAddress: String,
          amount: Int64,
          fee: Int64,
          assetId: String?,
          feeAssetId: String?) {
        guard let id = id,
            let senderPublicKey = senderPublicKey,
            let signature = signature,
            let timestamp = timestamp else {
                return nil;
        }
        self.id = id
        self.senderPublicKey = senderPublicKey
        self.signature = signature
        self.attachment = attachment
        self.timestamp = timestamp
        self.amount = amount
        self.fee = fee
        self.assetId = assetId
        self.feeAssetId = feeAssetId
        self.recipient = recipientAddress
    }
}
