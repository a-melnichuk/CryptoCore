//
//  TestTransaction.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 7/14/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import CryptoCore
import EthereumCore
import BigInt

class TestTransaction: XCTestCase {

    struct Token: ERC20TokenProtocol {
        var erc20TokenContractAddress: String
    }
    
    func testEthereumTransactionSerialization() {
        let privateKey = Hex.decode("b73b0b37bb2d8c592f12afcb9efcebbef1b1ea4ffcade496b22e9a2409c56e87")!
        let sender = "0x9AC1164465565459eB3b7C1ddE59914AD4Aff361"
        let recipient = "0x21a86dfe35a4cc54ad024402ab087a9f8efe77b9"
        let token = Token(erc20TokenContractAddress: "0x95a41fb80ca70306e9ecf4e51cea31bd18379c18")
        let tx = EthereumCore.Transaction.Transfer(
            sender: sender,
            recipient: recipient,
            amount: BigUInt("1000000000000000000"),
            nonce: 76,
            gasPrice: 1500000000,
            gasLimit: 63234,
            ethBalance: nil,
            token: token)
        do {
            let signed = try tx.sign(privateKey: privateKey)
            XCTAssertEqual(signed.serializedTransactionHex, "0xf8a84c8459682f0082f7029495a41fb80ca70306e9ecf4e51cea31bd18379c1880b844a9059cbb00000000000000000000000021a86dfe35a4cc54ad024402ab087a9f8efe77b90000000000000000000000000000000000000000000000000de0b6b3a764000026a09167f001f46ccb446515695bb62531cdd24794748748af63ede990b0d9879782a06c024f1479fa4fc816814729011995fcdd09765c4259a7fed43b23b2a2034c4f")
        } catch {
            XCTFail("Error \(error)")
        }
        
    }
}
