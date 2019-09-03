//
//  String+Extension.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 9/3/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public extension String {
    func isValidBitcoinOrAltcoinAddress(_ address: String, network: Network) -> Bool {
        if Base58Check.valid(address, version: network.pubkeyhash) {
            return true
        }
        return BitcoinCore.isSegwitAddress(address, network: network)
    }
}
