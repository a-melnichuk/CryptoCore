//
//  NEMTransferTransaction.swift
//  NEMCore
//
//  Created by Alex Melnichuk on 6/7/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public extension NEMCore {
    struct Transfer {
        public struct Signed {
            public let amount: UInt64
            public let fee: UInt64
        }
        /// The amount of micro XEM that is transferred from sender to recipient.
        public let amount: UInt64
        /// The address of the recipient.
        public let recipient: String
        /// The message of the transaction.
        public let message: Message?
        /// NEM Tokens
        public let mosaics: [NEMTransferTransactionMosaicProtocol]
        /// NEM balance
        public let balance: UInt64?
        
        public init(amount: UInt64,
                    recipient: String,
                    message: Message?,
                    mosaics: [NEMTransferTransactionMosaicProtocol],
                    balance: UInt64?) {
            self.amount = amount
            self.recipient = recipient
            self.message = message 
            self.mosaics = mosaics
            self.balance = balance
        }
    }
}

extension NEMCore.Transfer: NEMTransactionPart {
    
    public var kind: NEMCore.Transaction<NEMCore.Transfer>.Kind {
        return .transferTransaction
    }
    
    public func calculateFee(_ transaction: NEMCore.Transaction<NEMCore.Transfer>,
                             privateKey: inout Data,
                             publicKey: Data) throws -> UInt64 {
        return NEMCore.Transfer.fee(for: amount,
                                    message: message?.message,
                                    messageEncrypted: message?.kind == .encrypted,
                                    mosaics: mosaics)
    }
    
    /// Generates the common part of the transaction data byte array.
    /// - Parameter transaction: The transaction for which the common part of the transaction data byte array should get generated.
    /// - Returns: The common part of the transaction data byte array.
    public func signTransaction(_ transaction: NEMCore.Transaction<NEMCore.Transfer>,
                                privateKey: inout Data,
                                publicKey: Data,
                                fee: UInt64) throws -> (serialized: Data, signed: NEMCore.Transfer.Signed) {
        var fee = fee
        var amount = self.amount
        
        let recipient = NEMCore.denormalize(address: self.recipient)
        
        guard fee > 0 else {
            throw NEMCore.TransactionError.invalidFee
        }
        
        if mosaics.isEmpty {
            guard amount > 0 else {
                throw NEMCore.TransactionError.invalidAmount
            }
            guard amount > fee else {
                throw NEMCore.TransactionError.invalidAmount
            }
            
            guard let sender = NEMCore.address(publicKey: publicKey, networkByte: transaction.networkByte),
                recipient != NEMCore.denormalize(address: sender) else {
                    throw NEMCore.TransactionError.cannotSendToSelf
            }
            
            if amount == balance {
                guard amount > fee else {
                    throw NEMCore.TransactionError.feeExceedsBalance
                }
                let amountWithoutFee = amount - fee
                // NEM's fee depends on amount. When amount changes, fee needs recalculation
                fee = NEMCore.Transfer.fee(for: amountWithoutFee, message: message?.message)
                if fee >= amount {
                    throw NEMCore.TransactionError.invalidAmount
                }
                amount -= fee
            }
        } else if let balance = self.balance {
            guard balance > fee else {
                throw NEMCore.TransactionError.feeExceedsBalance
            }
        }
        
        let recipientAddressLengthByteArray = min(40, recipient.count).nemSerialized
        let recipientAddressByteArray = recipient.nemSerialized
        let amountByteArray = Data(loadBytes: amount.littleEndian)
        let messageByteArray = message?.serialized() ?? 0.nemSerialized
        let mosaicByteArray = transaction.version == 2 ? mosaics.nemSerialized() : Data()
        
        var data = Data()
        data.append(recipientAddressLengthByteArray)
        data.append(recipientAddressByteArray)
        data.append(amountByteArray)
        data.append(messageByteArray)
        data.append(mosaicByteArray)
        
        let signed = Signed(amount: amount, fee: fee)
        
        return (serialized: data, signed: signed)
    }
}
