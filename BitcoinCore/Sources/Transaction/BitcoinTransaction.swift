//
//  BitcoinTransaction.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 6/4/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import paytomat_btc_core

public extension BitcoinCore {
    struct Transaction {
        /// Transaction data format version (note, this is signed)
        public let version: Int32
        /// If present, always 0001, and indicates the presence of witness data
        // let flag: UInt16 // If present, always 0001, and indicates the presence of witness data
        /// Number of Transaction inputs (never zero)
        
        public let persentHash: Data?
        
        public let txInCount: VarInt
        /// A list of 1 or more transaction inputs or sources for coins
        public let inputs: [Input]
        /// Number of Transaction outputs
        public let txOutCount: VarInt
        /// A list of 1 or more transaction outputs or destinations for coins
        public let outputs: [Output]
        /// A list of witnesses, one for each input; omitted if flag is omitted above
        // let witnesses: [TransactionWitness] // A list of witnesses, one for each input; omitted if flag is omitted above
        /// The block number or timestamp at which this transaction is unlocked:
        public let lockTime: UInt32
        
        public init(version: Int32,
                    persentHash: Data?,
                    inputs: [Input],
                    outputs: [Output],
                    lockTime: UInt32) {
            self.version = version
            self.persentHash = persentHash
            self.txInCount = VarInt(inputs.count)
            self.inputs = inputs
            self.txOutCount = VarInt(outputs.count)
            self.outputs = outputs
            self.lockTime = lockTime
        }
        
        func serialized() -> Data {
            var data = Data()
            data.append(Data(loadBytes: version))
            if version == 12, let persentHash = self.persentHash {
                data.append(Data(loadBytes: persentHash))
            }
            data.append(txInCount.serialized())
            inputs.forEach { data.append($0.serialized()) }
            data.append(txOutCount.serialized())
            outputs.forEach { data.append($0.serialized()) }
            data.append(Data(loadBytes: lockTime))
            return data
        }
    }
    
    enum TransactionError: Error {
        case invalidAddress
        case invalidAmount
        case invalidFee
        case contractCreationFailed(Error)
        case transferContractCreationFailed(Error)
        case signatureFailed
        case encodingFailed
        case amountTooSmall
        case invalidUTXOs
        case invalidTotalInputAmount
        case invalidTxId
        case invalidSubScript
    }
}

public extension BitcoinCore.Transaction {
    struct OutPoint {
        /// The hash of the referenced transaction.
        public let hash: Data
        /// The index of the specific output in the transaction. The first output is 0, etc.
        public let index: UInt32
        
        public init(hash: Data, index: UInt32) {
            self.hash = hash
            self.index = index
        }
        
        public func serialized() -> Data {
            var data = Data()
            data.append(contentsOf: hash.reversed())
            data.append(Data(loadBytes: index))
            return data
        }
    }
    
    struct Input {
        /// The previous output transaction reference, as an OutPoint structure
        public let previousOutput: OutPoint
        /// The length of the signature script
        public let scriptLength: VarInt
        /// Computational Script for confirming transaction authorization
        public let signatureScript: Data
        /// Transaction version as defined by the sender. Intended for "replacement" of transactions when information is updated before inclusion into a block.
        public let sequence: UInt32
        
        public init(previousOutput: OutPoint,
                    signatureScript: Data,
                    sequence: UInt32) {
            self.previousOutput = previousOutput
            self.scriptLength = VarInt(signatureScript.count)
            self.signatureScript = signatureScript
            self.sequence = sequence
        }
        
        public func serialized() -> Data {
            var data = Data()
            data.append(previousOutput.serialized())
            data.append(scriptLength.serialized())
            data.append(signatureScript)
            data.append(Data(loadBytes: sequence))
            return data
        }
    }
    
    struct Output {
        /// Transaction Value
        public let value: Int64
        /// Length of the pk_script
        public let scriptLength: VarInt
        /// Usually contains the public key as a Bitcoin script setting up conditions to claim this output
        public let lockingScript: Data
        
        public init(value: Int64, lockingScript: Data) {
            self.value = value
            self.scriptLength = VarInt(lockingScript.count)
            self.lockingScript = lockingScript
        }
        
        public func serialized() -> Data {
            var data = Data()
            data.append(Data(loadBytes: value))
            data.append(scriptLength.serialized())
            data.append(lockingScript)
            return data
        }
    }

}
