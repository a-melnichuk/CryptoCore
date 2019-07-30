//
//  Web3+Personal.swift
//  web3swift
//
//  Created by Alexander Vlasov on 14.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

/// Personal functions
public class Web3Personal: Web3OptionsInheritable {
    /// provider for some functions
    var provider: Web3Provider
    unowned var web3: Web3
    /// Default options
    var options: Web3Options {
        return web3.options
    }
	
	/// init with provider and web3 instanse
    init(provider prov: Web3Provider, web3 web3instance: Web3) {
        provider = prov
        web3 = web3instance
    }



    /**
     *Recovers a signer of some message. Message is first prepended by special prefix (check the "signPersonalMessage" method description) and then hashed.*
     
     - Parameter personalMessage: Message Data
     - Parameter signature: Serialized signature, 65 bytes
     - Returns: signer address

     */
    public func ecrecover(personalMessage: Data, signature: Data) throws -> Address {
        return try Web3Utils.personalECRecover(personalMessage, signature: signature)
    }

    /**
     *Recovers a signer of some hash. Checking what is under this hash is on behalf of the user.*
     
     - Parameter hash: Signed hash
     - Parameter signature: Serialized signature, 65 bytes
     - Returns: signer address

     */
    public func ecrecover(hash: Data, signature: Data) throws -> Address {
        return try Web3Utils.hashECRecover(hash: hash, signature: signature)
    }
}
