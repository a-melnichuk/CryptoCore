
//  Web3+Contract.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

/// Web3 instance bound contract instance.
public class Web3Contract {
    var contract: ContractProtocol
    var networkId: NetworkId
    /// Default options
    var options: Web3Options
    
    /// Initialize the bound contract instance by supplying the Web3 provider bound object, ABI, Ethereum address and some default
    /// options for further function calls. By default the contract inherits options from the web3 object. Additionally supplied "options"
    /// do override inherited ones.
    init(networkId: NetworkId, abiString: String, at: Address? = nil, options: Web3Options) throws {
        self.networkId = networkId
        self.options = options
        contract = try ContractV2(abiString, at: at)
        if at != nil {
            contract.address = at
            self.options.to = at
        } else if let addr = self.options.to {
            contract.address = addr
        }
    }
    
    /// Creates and object responsible for calling a particular function of the contract. If method name is not found in ABI - Returns nil.
    /// If extraData is supplied it is appended to encoded function parameters. Can be usefull if one wants to call
    /// the function not listed in ABI. "Parameters" should be an array corresponding to the list of parameters of the function.
    /// Elements of "parameters" can be other arrays or instances of String, Data, BigInt, BigUInt, Int or Address.
    ///
    /// Returns a "Transaction intermediate" object.
    func method(_ name: String = "fallback", args: Any..., extraData: Data = Data(), options: Web3Options?) throws -> TransactionIntermediate {
        return try method(name, parameters: args, extraData: extraData, options: options)
    }
    
    func method(_ method: String = "fallback", parameters: [Any], extraData: Data = Data(), options: Web3Options?) throws -> TransactionIntermediate {
        let mergedOptions = self.options.merge(with: options)
        var tx = try contract.method(method, parameters: parameters, extraData: extraData, options: mergedOptions)
        tx.chainID = networkId
        return TransactionIntermediate(transaction: tx, contract: contract, method: method, options: mergedOptions)
    }
}
