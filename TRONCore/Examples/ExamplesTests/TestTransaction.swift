//
//  TestTransaction.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 7/14/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import CryptoCore
import TRONCore
import paytomat_trx_core

class TestTransaction: XCTestCase {

    func testSign() {
        let data = Hex.decode("0a020c5822080cb622403aeb9b2c40ffa7ad90d22d5a65080112610a2d747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e73666572436f6e747261637412300a1541afc68a4257addb9a859027d62ba79d53d0da15fe1215418351ef27a36b8fd60319b9d820e40d582794b44d180170ff8598ffd12d")!
        let privateKey = Hex.decode("1aa7e709aed6287b6a22634ad8c29356330fd042da80f51bc671e383a7bf5893")!
        let sign = "11528bad269add8115cb421a9ec66ec2bb2202ad32b338fab3912b844a34b739b9aef11fc0a5030aa0954837aec6eba27ab7d6636d2b0f47cd44d644523048d200"
        var signature = Data(count: Int(65))
        let result = signature.withUnsafeMutableBytes { signaturePtr in
            data.withUnsafeBytes { dataPtr in
                privateKey.withUnsafeBytes { privateKeyPtr in
                    ptc_trx_sign_transaction(dataPtr, data.count, privateKeyPtr, privateKey.count, signaturePtr)
                }
            }
        }
        XCTAssertEqual(Hex.encode(signature), sign)
    }

}
