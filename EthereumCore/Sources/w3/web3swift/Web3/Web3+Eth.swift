//
//  Web3+Eth.swift
//  web3swift
//
//  Created by Alexander Vlasov on 22.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

/// Extension located
public class Web3Eth: Web3OptionsInheritable {
    /// provider for some functions
    var provider: Web3Provider
    unowned var web3: Web3
    /// Default options
    var options: Web3Options {
        return web3.options
    }
	
	/// init with web3 provider and web3
    init(provider prov: Web3Provider, web3 web3instance: Web3) {
        provider = prov
        web3 = web3instance
    }
 
}
