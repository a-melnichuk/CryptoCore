//
//  WavesTransaction.swift
//  NEMCore
//
//  Created by Alex Melnichuk on 6/4/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import paytomat_nem_core

public protocol NEMTransactionPart {
    associatedtype Signed
    var kind: NEMCore.Transaction<Self>.Kind { get }
    
    func calculateFee(_ transaction: NEMCore.Transaction<Self>,
                      privateKey: inout Data,
                      publicKey: Data) throws -> UInt64
    
    func signTransaction(_ transaction: NEMCore.Transaction<Self>,
                         privateKey: inout Data,
                         publicKey: Data,
                         fee: UInt64) throws -> (serialized: Data, signed: Signed)
}

public extension NEMCore {
    struct Transaction<T: NEMTransactionPart> {
        public static var deadline: Int64 {
            return 21600
        }
        
        public static var genesisBlockTime: Int64 {
            return 1427587585
        }
        
        public enum Kind: Int {
            case transferTransaction = 257
            case importanceTransferTransaction = 2049
            case multisigTransaction = 4100
            case multisigSignatureTransaction = 4098
            case multisigAggregateModificationTransaction = 4097
        }
        
        public struct Signed {
            /// The transaction data as string. The string is created by first
            /// creating the corresponding byte array and then converting the byte array
            /// to a hexadecimal string.
            public let data: String
            /// The signature for the transaction as hexadecimal string.
            public let signature: String
            public let signedTransaction: T.Signed
        }
        
        /// The version of the transaction.
        public let version: Int
        /// The number of seconds elapsed since the creation of the nemesis block.
        public let timestamp: Int64
        /// The deadline of the transaction.
        public let deadline: Int64
        public let networkByte: UInt8
        public let transaction: T
        
        public init(version: Int,
                    timestamp: Int64? = nil,
                    timeOffset: Int64 = 0,
                    deadline: Int64? = nil,
                    networkByte: UInt8 = NEMCore.mainnetNetworkByte,
                    transaction: T) {
            let genesisBlockTimeInMilliseconds = Transaction<T>.genesisBlockTime * 1000
            let timestamp = timestamp ?? Int64((Date().timeIntervalSince1970 * 1000.0).rounded())
            let deadline = deadline ?? (timestamp + Transaction<T>.deadline * 1000)
            self.version = version
            self.timestamp = (timestamp + timeOffset - genesisBlockTimeInMilliseconds) / 1000
            self.deadline = (deadline + timeOffset - genesisBlockTimeInMilliseconds) / 1000
            self.networkByte = networkByte
            self.transaction = transaction
        }
    }
    
    enum TransactionError: Error {
        case invalidAmount
        case invalidFee
        case invalidBalance
        case feeExceedsBalance
        case cannotSendToSelf
        case publicKeyGenerationFailed
        case signatureFailed
    }
}

extension NEMCore.Transaction.Signed: Encodable {
    private enum CodingKeys: String, CodingKey {
        case data
        case signature
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encode(signature, forKey: .signature)
    }
}

public extension NEMCore.Transaction {
    func sign(privateKey: inout Data) throws -> Signed {
        guard let publicKey = NEMCore.publicKey(privateKey: privateKey) else {
            throw NEMCore.TransactionError.publicKeyGenerationFailed
        }
        
        let fee = try transaction.calculateFee(self,
                                               privateKey: &privateKey,
                                               publicKey: publicKey)
        let commonTransactionPart = try self.commonTransactionPart(publicKey: publicKey, fee: fee)
        let (customTransactionPart, signedTransaction) = try transaction.signTransaction(
            self,
            privateKey: &privateKey,
            publicKey: publicKey,
            fee: fee)
        
        var data = Data()
        data.append(commonTransactionPart)
        data.append(customTransactionPart)
        
        guard let transactionSignatureByteArray = NEMCore.sign(data, privateKey: &privateKey) else {
            throw NEMCore.TransactionError.signatureFailed
        }
        let dataHex = Crypto.hex(fromData: data)
        let signatureHex = Crypto.hex(fromData: transactionSignatureByteArray)
        return Signed(data: dataHex,
                      signature: signatureHex,
                      signedTransaction: signedTransaction)
    }
    
    private func commonTransactionPart(publicKey: Data, fee: UInt64) throws -> Data {
        let transactionPublicKeyLengthByteArray = min(32, publicKey.count).nemSerialized
        let transactionTypeByteArray = transaction.kind.rawValue.nemSerialized
        let transactionVersionByteArray = Data([UInt8](arrayLiteral: UInt8(version), 0, 0, networkByte))
        let transactionTimeStampByteArray = Data(loadBytes: Int32(timestamp).littleEndian)
        let transactionSignerByteArray = publicKey
        let transactionFeeByteArray = Data(loadBytes: fee)
        let transactionDeadlineByteArray = Data(loadBytes: Int32(deadline).littleEndian)
        
        var data = Data()
        data.append(transactionTypeByteArray)
        data.append(transactionVersionByteArray)
        data.append(transactionTimeStampByteArray)
        data.append(transactionPublicKeyLengthByteArray)
        data.append(transactionSignerByteArray)
        data.append(transactionFeeByteArray)
        data.append(transactionDeadlineByteArray)
        return data
    }
}
