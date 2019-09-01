//
//  BitcoinTransfer.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 8/30/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public extension BitcoinCore.Transaction {
    struct Transfer {
        
        public let network: Network
        
        /// version = ver = int32_t Transaction data format version (note, this is signed);
        public let version: Int32
        
        /// Sequence numbers are intended to be used for replacement. Replacement is currently disabled, but how it would work is:
        /// - You send a transaction with a LockTime in the future and a sequence number of 0. The transaction is then not considered by the network to be "final", and it can't be included in a block until the specified LockTime is reached.
        /// - Before LockTime expires, you can replace the transaction with as many new versions as you want. Newer versions have higher sequence numbers.
        /// - If you ever want to lock the transaction permanently, you can set the sequence number to `UINT32_MAX`. Then the transaction is considered to be final, even if LockTime has not been reached.
        
        public let sequence: UInt32 // 0xffffff
        
        /// `lock_time` - The block number or timestamp at which this transaction is unlocked:
        ///
        /// 0 - Not locked
        ///
        /// < 500000000 - Block number at which this transaction is unlocked
        ///
        /// >= 500000000 - UNIX timestamp at which this transaction is unlocked
        ///
        /// If all TxIn inputs have final (0xffffffff) sequence numbers then lock_time is irrelevant. Otherwise, the transaction may not be added to a block until after lock_time
        
        public let lockTime: UInt32
        
        public let senderPublicKey: Data
        public let recipientAddress: String
        
        /// when `computeFeePerByte` == true, fee is multiplied with transaction size
        
        public let fee: Int64
        
        /// Sender's transferred amount in satoshis
        
        public let amount: Int64
        public let dust: Int64?
        public let blockInfo: BlockInfo
        
        public init(network: Network,
                    senderPublicKey: Data,
                    recipientAddress: String,
                    fee: Int64,
                    amount: Int64,
                    version: Int32,
                    sequence: UInt32 = UInt32.max,
                    lockTime: UInt32 = 0,
                    dust: Int64?,
                    blockInfo: BlockInfo) {
            self.network = network
            self.senderPublicKey = senderPublicKey
            self.recipientAddress = recipientAddress
            self.fee = fee
            self.amount = amount
            self.version = version
            self.sequence = sequence
            self.lockTime = lockTime
            self.dust = dust
            self.blockInfo = blockInfo
        }
        
        public struct Signed {
            public let amount: Int64
            public let transactionHex: String
        }
    }
}

public extension BitcoinCore.Transaction.Transfer {
    private typealias TransactionError = BitcoinCore.TransactionError
    private typealias Transaction = BitcoinCore.Transaction
    
    /// Serializes transaction into byte array
    ///
    /// [Transaciton steps were copied from here.](https://bitcoin.stackexchange.com/questions/3374/how-to-redeem-a-basic-tx)
    ///
    /// Steps 3-7 and 14-18 are repeated for each input.
    ///
    /// 1. Add four-byte version field: `01000000`
    /// 2. One-byte varint specifying the number of inputs: `01`
    /// 3. 32-byte hash of the transaction from which we want to redeem an output: `eccf7e3034189b851985d871f91384b8ee357cd47c3024736e5676eb2debb3f2`
    /// 4. Four-byte field denoting the output index we want to redeem from the transaction with the above hash (output number 2 = output index 1): `01000000`
    /// 5. Now comes the scriptSig. For the purpose of signing the transaction, this is temporarily filled with the `scriptPubKey` of the output we want to redeem. First we write a one-byte varint which denotes the length of the `scriptSig` (0x19 = 25 bytes): `19`
    /// 6. Then we write the temporary scriptSig which, again, is the scriptPubKey of the output we want to redeem: `76a914010966776006953d5567439e5e39f86a0d273bee88ac`
    /// 7. Then we write a four-byte field denoting the sequence. This is currently always set to `0xffffffff`: `ffffffff`
    /// 8. Next comes a one-byte varint containing the number of outputs in our new transaction. We will set this to 1 in this example: `01`
    /// 9. We then write an 8-byte field (64 bit integer) containing the amount we want to redeem from the specified output. I will set this to the total amount available in the output minus a fee of 0.001 BTC (0.999 BTC, or 99900000 Satoshis): `605af40500000000`
    /// 10. Then we start writing our transaction's output. We start with a one-byte varint denoting the length of the output script (0x19 or 25 bytes): 19
    /// 11. Then the actual output script: `76a914097072524438d003d23a2f23edb65aae1bb3e46988ac`
    /// 12. Then we write the four-byte "lock time" field: `00000000`
    /// 13. And at last, we write a four-byte "hash code type" (1 in our case): `01000000`
    ///
    ///     We now have the following raw transaction data:
    ///
    ///         01000000
    ///         01
    ///         eccf7e3034189b851985d871f91384b8ee357cd47c3024736e5676eb2debb3f2
    ///         01000000
    ///         19
    ///         76a914010966776006953d5567439e5e39f86a0d273bee88ac
    ///         ffffffff
    ///         01
    ///         605af40500000000
    ///         19
    ///         76a914097072524438d003d23a2f23edb65aae1bb3e46988ac
    ///         00000000
    ///         01000000
    /// 14. (signing stage) Now we double-SHA256 hash this entire structure, which yields the hash 9302bda273a887cb40c13e02a50b4071a31fd3aae3ae04021b0b843dd61ad18e
    /// 15. We then create a public/private key pair out of the provided private key. We sign the hash from step 14 with the private key, which yields the following DER-encoded signature (this signature will be different in your case): 30460221009e0339f72c793a89e664a8a932df073962a3f84eda0bd9e02084a6a9567f75aa022100bd9cbaca2e5ec195751efdfac164b76250b1e21302e51ca86dd7ebd7020cdc06 To this signature we append the one-byte hash code type: 01. The public key is: 0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6
    /// 16. We construct the final scriptSig by concatenating: <One-byte script OPCODE containing the length of the DER-encoded signature plus 1 (the length of the one-byte hash code type)>|< The actual DER-encoded signature plus the one-byte hash code type>|< One-byte script OPCODE containing the length of the public key>|<The actual public key>
    /// 17. We then replace the one-byte, varint length-field from step 5 with the length of the data from step 16. The length is 140 bytes, or 0x8C bytes: 8c
    /// 18. And we replace the temporary scriptSig from Step 6 with the data structure constructed in step 16. This becomes: 4930460221009e0339f72c793a89e664a8a932df073962a3f84eda0bd9e02084a6a9567f75aa022100bd9cbaca2e5ec195751efdfac164b76250b1e21302e51ca86dd7ebd7020cdc0601410450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6
    /// 19. We finish off by removing the four-byte hash code type we added in step 13, and we end up with the following stream of bytes, which is the final transaction:
    ///         01000000
    ///         01
    ///         eccf7e3034189b851985d871f91384b8ee357cd47c3024736e5676eb2debb3f2
    ///         01000000
    ///         8c
    ///         4930460221009e0339f72c793a89e664a8a932df073962a3f84eda0bd9e02084a6a9567f75aa022100bd9cbaca2e5ec195751efdfac164b76250b1e21302e51ca86dd7ebd7020cdc0601410450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6
    ///         ffffffff
    ///         01
    ///         605af40500000000
    ///         19
    ///         76a914097072524438d003d23a2f23edb65aae1bb3e46988ac
    ///         00000000
    /// - throws:
    ///     `TransactionError`:
    ///     - `.invalidTotalInputAmount` when `totalInputAmount` is 0 or `totalInputAmount` less or equals to `amount` (since  `totalInputAmount` - `amount` - `fee` cannot be negative)
    ///     - `.invalidAmount` when `amount` is 0
    ///     - `.invalidFee` when `fee` is 0
    ///     - `.invalidUTXOs` when no `utxos` were found
    ///     - `.invalidKeyPairs` when invalid utxo supply was passed for `utxos`
    ///     - `.invalidTxId` when hex decoding of `utxo.txHex` fails
    ///     - `.invalidSubScript` when hex decoding of `utxo.subScriptHex` fails
    ///     - `.invalidChange` when `totalInputAmount` - `amount` - `fee` <= 0
    ///     - `.signatureFailed` when `Crypto.sign` fails to sign transaction
    /// - returns:
    /// Signature struct with recalculated amount and transaction hex
    
    func sign(utxoKeyPairs: [UTXOKeyPair]) throws -> Signed {
        
        let totalInputAmount = utxoKeyPairs.map { $0.utxo.value }.reduce(0, +)
        var amount = self.amount
        guard totalInputAmount > 0 && totalInputAmount >= amount else {
            throw TransactionError.invalidTotalInputAmount
        }
        guard amount > 0 else {
            throw TransactionError.invalidAmount
        }
        
        guard !utxoKeyPairs.isEmpty else {
            throw TransactionError.invalidUTXOs
        }
        
        
        let recipientIsSegwit = BitcoinCore.isSegwitAddress(recipientAddress, network: network)
        
        let decodedUtxos = try utxoKeyPairs.map { utxoKeyPair -> DecodedUTXO in
            let utxo = utxoKeyPair.utxo
            let privateKey = utxoKeyPair.privateKey
            let publicKey = utxoKeyPair.publicKey
            guard let txId = Hex.decode(utxo.txHex) else {
                throw TransactionError.invalidTxId
            }
            guard let subScript = Hex.decode(utxo.subScriptHex) else {
                throw TransactionError.invalidSubScript
            }
            
            // Caution: split by `OP_CODESEPARATOR` is not implemented
            // A new subscript is created from the instruction from the most recently parsed `OP_CODESEPARATOR` (last one in script) to the end of the script.
            // If there is no `OP_CODESEPARATOR` the entire script becomes the subscript (hereby referred to as subScript)
            return DecodedUTXO(privateKey: privateKey,
                               publicKey: publicKey,
                               txId: txId,
                               address: utxo.address,
                               subScript: subScript,
                               vout: utxo.outputIndex,
                               value: utxo.value)
        }
        
        // lockingScript = pk_script = Usually contains the public key as a Bitcoin script setting up conditions to claim this output.
        // Public Key Hash is equivalent to the bitcoin address of the cafe, without the Base58Check encoding.
        // Most applications would show the public key hash in hexadecimal encoding and not the familiar bitcoin address Base58Check format that begins with a "1."
        
        // Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
        // Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
        // Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
        guard let externalPubKeyHash = BitcoinCore.hash160(network: network, address: recipientAddress),
            let externalPkScipt = recipientIsSegwit
                ? network.buildP2WPKHScript(pubKeyHash: externalPubKeyHash, blockInfo: blockInfo)
                : network.buildP2PKHScript(pubKeyHash: externalPubKeyHash, blockInfo: blockInfo) else {
                    throw BitcoinCore.TransactionError.encodingFailed
        }
        
        let inputs: [Transaction.Input]
        let outputs: [Transaction.Output]
        
        if amount >= totalInputAmount {
            amount = min(totalInputAmount, amount)
            // user transafer's total balance of wallet
            let dummyExternalOutput = Transaction.Output(value: amount, lockingScript: externalPkScipt)
            let totalFee = try computeTransactionFee(network: network,
                                                     totalInputAmount: totalInputAmount,
                                                     fee: fee,
                                                     changePkScipt: nil,
                                                     externalOutput: dummyExternalOutput,
                                                     utxos: decodedUtxos)
            guard amount > totalFee else {
                throw TransactionError.amountTooSmall
            }
            amount -= totalFee
            let externalOutput = Transaction.Output(value: amount, lockingScript: externalPkScipt)
            outputs = [externalOutput]
            inputs = try createSignedInputs(utxos: decodedUtxos, outputs: outputs)
        } else {
            guard let changePubKeyHash = Crypto.sha256ripemd160(senderPublicKey),
                let changePkScipt = network.buildP2PKHScript(pubKeyHash: changePubKeyHash, blockInfo: blockInfo) else {
                    throw BitcoinCore.TransactionError.encodingFailed
            }
            var externalOutput = Transaction.Output(value: amount, lockingScript: externalPkScipt)
            // calculate fee and create real transaction
            let totalFee = try computeTransactionFee(network: network,
                                                     totalInputAmount: totalInputAmount,
                                                     fee: fee,
                                                     changePkScipt: changePkScipt,
                                                     externalOutput: externalOutput,
                                                     utxos: decodedUtxos)
            var change = totalInputAmount - amount - totalFee
    
            if change < 0 {
                amount += change
                change = 0
                externalOutput = Transaction.Output(value: amount, lockingScript: externalPkScipt)
            }
            
            guard amount > 0 else {
                throw TransactionError.amountTooSmall
            }
            
            if let dust = dust, change < dust {
                // change in blockchain cannot be less, than dust, serialize transaction with one output
                outputs = [externalOutput]
            } else if change <= 0 {
                outputs = [externalOutput]
            } else {
                let changeOutput = Transaction.Output(value: change, lockingScript: changePkScipt)
                outputs = [externalOutput, changeOutput]
            }
            
            inputs = try createSignedInputs(utxos: decodedUtxos, outputs: outputs)
        }
        
        let tx = Transaction(version: version,
                             persentHash: blockInfo.blockHash,
                             inputs: inputs,
                             outputs: outputs,
                             lockTime: lockTime)
        let txBytes = tx.serialized()
        
        return Signed(amount: amount, transactionHex: Hex.encode(txBytes))
    }
    
    private func computeTransactionFee(network: Network,
                                       totalInputAmount: Int64,
                                       fee: Int64,
                                       changePkScipt: Data?,
                                       externalOutput: Transaction.Output,
                                       utxos: [DecodedUTXO]) throws -> Int64 {
        if network.hasStaticFees {
            return fee
        }
        let txSize = try computeTransactionSize(totalInputAmount: totalInputAmount,
                                                changePkScipt: changePkScipt,
                                                externalOutput: externalOutput,
                                                utxos: utxos)
        return fee * txSize
    }
    
    private func computeTransactionSize(totalInputAmount: Int64,
                                        changePkScipt: Data?,
                                        externalOutput: Transaction.Output,
                                        utxos: [DecodedUTXO]) throws -> Int64 {
        let outputs: [Transaction.Output]
        if let changePkScipt = changePkScipt {
            let dummyChangeOutput = Transaction.Output(value: totalInputAmount - amount, lockingScript: changePkScipt)
            outputs = [externalOutput, dummyChangeOutput]
        } else {
            outputs = [externalOutput]
        }
        let dummyInputs = try createSignedInputs(utxos: utxos, outputs: outputs)
        let dummyTx = Transaction(version: version,
                                  persentHash: blockInfo.blockHash,
                                  inputs: dummyInputs,
                                  outputs: outputs,
                                  lockTime: lockTime)
        return Int64(dummyTx.serialized().count)
    }
    
    /// When you have more than 1 input, you don't have to remove the inputs that you are not going to sign, you have to remove only their scripts
    ///
    /// [Transaction input creation details](https://en.bitcoin.it/wiki/OP_CHECKSIG)
    ///
    /// [Useful diagram](https://en.bitcoin.it/wiki/File:Bitcoin_OpCheckSig_InDetail.png)
    ///
    /// Step by step algorithm:
    /// 1. A copy is made of the current transaction (hereby referred to `txCopy`)
    /// 2. Set all `txIn` scripts in `txCopy` to empty strings. Make sure `VarInt`'s representing script length are reevaluated to a single `0x00` byte for each `txIn`
    /// 3. Copy `subScript` into the `txIn` script you are checking. Make sure `VarInt` preceding `subScript` is reevaluated to represent size of `subScript`
    /// - parameters:
    ///     - utxos: Decoded from hex UTXO info to be used in transaction input
    ///     - outputs: Transaction outputs to put into signature transaction
    /// - returns:
    /// Array of signed transaction inputs
    
    private func createSignedInputs(utxos: [DecodedUTXO], outputs: [Transaction.Output]) throws -> [Transaction.Input] {
        
        return try utxos.enumerated().map { (i, utxo) -> Transaction.Input in
            let sigInputs = utxos.enumerated().map { (j, innerUtxo) -> Transaction.Input in
                let subScript = i == j ? innerUtxo.subScript : Data()
                return Transaction.Input(previousOutput: innerUtxo.output,
                                         signatureScript: subScript,
                                         sequence: sequence)
            }
            
            let sigTx = Transaction(version: version,
                                    persentHash: blockInfo.blockHash,
                                    inputs: sigInputs,
                                    outputs: outputs,
                                    lockTime: lockTime)
            var sigDigest = Data()
            sigDigest.append(sigTx.serialized())
            sigDigest.append(Data(loadBytes: UInt32(Signature.SIGHASH_ALL).littleEndian))
            guard let sigTxHash = Crypto.sha256sha256(sigDigest),
                let sig = BitcoinCore.sign(sigTxHash, privateKeyBytes: utxo.privateKey) else {
                    throw TransactionError.signatureFailed
            }
            let scriptSig = createScriptSig(sig: sig, pubkey: utxo.publicKey)
            return Transaction.Input(previousOutput: utxo.output,
                                     signatureScript: scriptSig,
                                     sequence: sequence)
        }
    }
    
    /// Signature script: `<sig> <pubkey>`
    ///
    /// We construct the final scriptSig by concatenating:
    ///
    /// `<One-byte script OP_CODE containing the length of the DER-encoded signature plus 1 (the length of the one-byte hash code type)>`
    ///
    /// `<The actual DER-encoded signature plus the one-byte hash code type>`
    ///
    /// `< One-byte script OP_CODE containing the length of the public key>`
    ///
    /// `<The actual public key>`
    
    private func createScriptSig(sig: Data, pubkey: Data) -> Data {
        var data = Data([UInt8(sig.count + 1)])
        data.append(sig)
        data.append(Signature.SIGHASH_ALL)
        data.append(UInt8(pubkey.count))
        data.append(pubkey)
        return data
    }
}

