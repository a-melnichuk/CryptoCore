//
//  Web3+Instance.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation


/// A web3 instance bound to provider. All further functionality is provided under web.*. namespaces.
class Web3: Web3OptionsInheritable {

    /// Web3 provider. Contains Keystore Manager, node URL and Network id
    var provider: Web3Provider
    /// Default options. Merges with provided options in every transaction
    var options: Web3Options = .default
    /// default block. default: "latest"
    var defaultBlock = "latest"

    /// Public web3.eth.* namespace.
    lazy var eth = Web3Eth(provider: self.provider, web3: self)

    /// Raw initializer using a Web3Provider protocol object, dispatch queue and request dispatcher.
    init(provider prov: Web3Provider) {
        provider = prov
       
    }
}
