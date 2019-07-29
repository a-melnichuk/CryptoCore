//
//  EthereumTransaction.swift
//  EthereumCore
//
//  Created by Alex Melnichuk on 6/4/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import paytomat_eth_core
import struct BigInt.BigUInt

public extension EthereumCore {
    struct Transaction {}
    
    enum TransactionError: Error {
        case invalidAddress
        case invalidAmount
        case invalidFee
        case contractCreationFailed(Error)
        case transferContractCreationFailed(Error)
        case cannotSendToSelf
        case signatureFailed
        case encodingFailed
        case notEnoughGas
    }
}

public extension EthereumCore.Transaction {
    struct Transfer {
        public struct Signed {
            public let from: EthereumAddress
            public let to: EthereumAddress
            public let amount: BigUInt
            public let transaction: EthereumTransaction
            public let serializedTransactionHex: String
        }
        
        public let chainId: NetworkId
        public let sender: String
        public let recipient: String
        public let amount: BigUInt
        public let nonce: BigUInt
        public let gasPrice: BigUInt
        public let gasLimit: BigUInt
        public let ethBalance: BigUInt?
        public let token: ERC20TokenProtocol?
        
        public init(chainId: NetworkId = EthereumCore.frontierChainId,
                    sender: String,
                    recipient: String,
                    amount: BigUInt,
                    nonce: BigUInt,
                    gasPrice: BigUInt,
                    gasLimit: BigUInt,
                    ethBalance: BigUInt?,
                    token: ERC20TokenProtocol?) {
            self.chainId = chainId
            self.sender = sender
            self.recipient = recipient
            self.amount = amount
            self.nonce = nonce
            self.gasPrice = gasPrice
            self.gasLimit = gasLimit
            self.ethBalance = ethBalance
            self.token = token
        }
    }
}

public extension EthereumCore.Transaction.Transfer {
    func sign(privateKey: Data) throws -> Signed {
        let recipient = EthereumAddress(token?.erc20TokenContractAddress ?? self.recipient)
        let sender = EthereumAddress(self.sender)
        guard recipient.isValid && sender.isValid else {
            throw EthereumCore.TransactionError.invalidAddress
        }
        var amount = self.amount
        guard amount > 0 else {
            throw EthereumCore.TransactionError.invalidAmount
        }
        guard gasPrice > 0 else {
            throw EthereumCore.TransactionError.invalidFee
        }
        
        let fee = gasPrice * gasLimit
        let data: Data
        if let token = token {
            if let ethBalance = ethBalance, fee > ethBalance {
                 throw EthereumCore.TransactionError.notEnoughGas
            }
            let contract = ERC20TransferContract(token: token,
                                                 sender: sender,
                                                 recipient: recipient,
                                                 amount: amount)
            data = try contract.serialized()
        } else {
            guard self.recipient.lowercased() != self.sender.lowercased() else {
                throw EthereumCore.TransactionError.cannotSendToSelf
            }
            
            if let ethBalance = ethBalance {
                if amount == ethBalance {
                    amount -= fee
                    guard amount > 0 else {
                        throw EthereumCore.TransactionError.notEnoughGas
                    }
                } else if amount + fee > ethBalance {
                    throw EthereumCore.TransactionError.notEnoughGas
                }
                
            }
            if let ethBalance = ethBalance, amount == ethBalance {
                amount -= fee
            }
            data = Data()
        }
        
        // data - all of the interesting extra stuff goes here
        // v, r, s - v along with r and s makes up the ECDSA signature.
        // They can be used to get public key of any ethereum account.
        
        var tx = EthereumTransaction(nonce: nonce,
                                     gasPrice: gasPrice,
                                     gasLimit: gasLimit,
                                     to: recipient,
                                     value: token == nil ? amount : 0,
                                     data: data,
                                     v: BigUInt(0),
                                     r: BigUInt(0),
                                     s: BigUInt(0))
        
        // chain id [optional] - By including the chain identifier in the data being signed,
        // the transaction signature prevents any changes,
        // as the signature is invalidated if the chain identifier is modified.
        tx.UNSAFE_setChainID(chainId)
        
        do {
            try Web3Signer.EIP155Signer.sign(transaction: &tx, privateKey: privateKey)
        } catch {
            throw EthereumCore.TransactionError.signatureFailed
        }
        guard let txBytes = tx.encode(forSignature: false, chainId: chainId) else {
            throw EthereumCore.TransactionError.encodingFailed
        }
        let txHex = Hex.encode(txBytes).lowercased().withEthereumPrefix
        
        return Signed(from: sender,
                      to: recipient,
                      amount: amount,
                      transaction: tx,
                      serializedTransactionHex: txHex)
    }
}
