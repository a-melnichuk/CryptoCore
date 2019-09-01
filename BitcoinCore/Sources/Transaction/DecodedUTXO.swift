//
//  DecodedUTXO.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 8/30/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

struct DecodedUTXO {
    let privateKey: Data
    let publicKey: Data
    let address: String
    let subScript: Data
    let output: BitcoinCore.Transaction.OutPoint
    let value: Int64
}

extension DecodedUTXO {
    init(privateKey: Data,
         publicKey: Data,
         txId: Data,
         address: String,
         subScript: Data,
         vout: UInt32,
         value: Int64) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.address = address
        self.subScript = subScript
        self.output = BitcoinCore.Transaction.OutPoint(hash: txId, index: vout)
        self.value = value
    }
}
