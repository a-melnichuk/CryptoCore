//
//  UTXOProtocol.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 8/29/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

/// UTXO = Unspent Transaction Output
///
/// UTXO are needed for creation of Bitcoin/Altcoin transactions
/// UTXO's are fetched through blockchain's/server's API
///
/// In an accepted transaction in a valid blockchain payment system (such as Bitcoin), only unspent outputs can be used as inputs to a transaction.
///
/// When a transaction takes place, inputs are deleted and outputs are created as new UTXOs that may then be consumed in future transactions.

public struct UTXO {
    
    /// Address of the recipient
    
    public var address: String
    
    /// `hash` or `txid`: `char[32]` - The hash of the previous referenced transaction.
    
    public var txId: Data
    
    /// Transaction amount in bitcoins, initally parsed as `String`
    
    public var value: Int64
    
    /// `index` or `vout` is an output index - the index number of the UTXO to be spent
    ///
    /// `index` is chosen from previous output with sender's address, since the other outputs can, for example, act as change back for faucet's address
    
    public var outputIndex: UInt32
    
    /// Signature script: \<sig> \<pubkey>
    ///
    /// A new subscript is created from the instruction from the most recently parsed OP_CODESEPARATOR (last one in script) to the end of the script.
    ///
    /// If there is no `OP_CODESEPARATOR` the entire script becomes the subscript (hereby referred to as subScript)
    ///
    /// [Detailed description](https://en.bitcoin.it/wiki/OP_CHECKSIG)
    
    public var subScript: Data
    
    public var output: BitcoinCore.Transaction.OutPoint
    
    public init(address: String,
                txId: Data,
                value: Int64,
                outputIndex: UInt32,
                subScript: Data) {
        self.address = address
        self.txId = txId
        self.value = value
        self.outputIndex = outputIndex
        self.subScript = subScript
        self.output = BitcoinCore.Transaction.OutPoint(hash: txId, index: outputIndex)
    }
}

public struct UTXOKeyPair {
    public let utxo: UTXO
    public let privateKey: Data
    public let publicKey: Data
    
    public init(utxo: UTXO, privateKey: Data, publicKey: Data) {
        self.utxo = utxo
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}
