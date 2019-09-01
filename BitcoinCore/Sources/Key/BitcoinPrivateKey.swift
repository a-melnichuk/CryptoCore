//
//  BitcoinPrivateKey.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 9/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public class BitcoinPrivateKey: BaseBitcoinPrivateKey, AnyPrivateKey {
    public convenience required init?(seed: Seed) {
        self.init(seed: seed, network: Bitcoin(), segwit: false)
    }
    
    public convenience required init?(rawPrivateKey: String) {
        self.init(rawPrivateKey: rawPrivateKey, network: Bitcoin(), segwit: false)
    }
}
