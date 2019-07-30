//
//  Web3+Provider.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation


/// Providers abstraction for custom providers (websockets, other custom private key managers). At the moment should not be used.
public protocol Web3Provider {
    var network: NetworkId? { get set }
}
