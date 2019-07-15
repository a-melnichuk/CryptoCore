//
//  ERC20TransferContract.swift
//  EthereumCore
//
//  Created by Alex Melnichuk on 7/14/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import struct BigInt.BigUInt
import web3swift

struct ERC20TransferContract {
    let token: ERC20TokenProtocol
    let sender: EthereumAddress
    let recipient: EthereumAddress
    let amount: BigUInt
    
    func serialized() throws -> Data {
        let contractAddress = EthereumAddress(token.erc20TokenContractAddress)
        guard contractAddress.isValid else {
            throw EthereumCore.TransactionError.invalidAddress
        }
        var options = Web3Options.defaultOptions()
    
        options.from = sender
        options.to = contractAddress
        options.value = 0
        let web3 = Web3.InfuraMainnetWeb3()
        
        let contract: Web3Contract
        let transfer: Web3Contract.TransactionIntermediate
        do {
            contract = try web3.contract(Web3Utils.erc20ABI, at: contractAddress)
        } catch {
            throw EthereumCore.TransactionError.contractCreationFailed(error)
        }
        do {
            transfer = try contract.method("transfer",
                                           parameters: [recipient, amount] as [AnyObject],
                                           extraData: Data(),
                                           options: options)
        } catch {
            throw EthereumCore.TransactionError.transferContractCreationFailed(error)
        }
        return transfer.transaction.data
    }
}
