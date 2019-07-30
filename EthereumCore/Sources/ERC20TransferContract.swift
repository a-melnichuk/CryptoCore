//
//  ERC20TransferContract.swift
//  EthereumCore
//
//  Created by Alex Melnichuk on 7/14/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import struct BigInt.BigUInt

struct ERC20TransferContract {
    let networkId: NetworkId
    let token: ERC20TokenProtocol
    let sender: EthereumAddress
    let recipient: EthereumAddress
    let amount: BigUInt
    
    func serialized() throws -> Data {
        let contractAddress = EthereumAddress(token.erc20TokenContractAddress)
        guard contractAddress.isValid else {
            throw EthereumCore.TransactionError.invalidAddress
        }
        var options = Web3Options.default
        options.from = sender
        options.to = contractAddress
        options.value = 0

        let contract: Web3Contract
        let transfer: TransactionIntermediate
        do {
            contract = try Web3Contract(networkId: networkId, abiString: Web3Utils.erc20ABI, at: contractAddress, options: options)
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
