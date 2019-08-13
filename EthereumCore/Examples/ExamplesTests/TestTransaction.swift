//
//  TestTransaction.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 7/14/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import web3swift
import CryptoCore
import EthereumCore

class TestTransaction: XCTestCase {

    struct ERC20Token: ERC20TokenProtocol {
        var erc20TokenContractAddress: String
    }
    
    func testEthereumAddressValidation() {
        let address = "0xd05950FfF256542a3D4484802473965E8DB55A98"
        let hashData = Data(address.withoutEthereumPrefix.lowercased().utf8)
        let hash1 = CryptoCore.Crypto.sha3_256(hashData)
        let hash2 = CryptoCore.Crypto.keccak256(hashData)
        XCTAssertEqual(Hex.encode(hash1!), "28d466e0a231a1702e4b2fa3fcb5b0ed6ffa6cc6e420af0bc4c389dd2b58b481")
        XCTAssertEqual(Hex.encode(hash2!), "28d466e0a231a1702e4b2fa3fcb5b0ed6ffa6cc6e420af0bc4c389dd2b58b481")
        
        XCTAssertTrue(address.isValidEthereumAddress)
    }
    
        let promise = XCTestExpectation(description: "\(#function)")
        let queue = DispatchQueue(label: "\(#function)")
        queue.async {
            do {
                let privateKey = Hex.decode("<Private key>")!
                let sender = "<Sender>"
                let recipient = "<Recipient>"
                let web3 = Web3.InfuraMainnetWeb3()
                let txCount = try web3.eth.getTransactionCount(address: EthereumAddress(sender))
                let gasPrice = try web3.eth.getGasPrice()
                let tx = EthereumCore.Transaction.Transfer(sender: sender,
                                                           recipient: recipient,
                                                           amount: 10,
                                                           nonce: txCount,
                                                           gasPrice: gasPrice,
                                                           gasLimit: 21000,
                                                           ethBalance: nil,
                                                           token: nil)
                let signed = try tx.sign(privateKey: privateKey)
                let txString = String(signed.serializedTransactionHex.dropFirst(2))
                let txData = Hex.decode(txString)!
                _ = try web3.eth.sendRawTransaction(txData)
                promise.fulfill()
            } catch {
                XCTFail("Error: \(error)")
                promise.fulfill()
            }
        }
        wait(for: [promise], timeout: 30)
    }

    func testERC20TransactionRequest() {
        let promise = XCTestExpectation(description: "\(#function)")
        let queue = DispatchQueue(label: "\(#function)")
        queue.async {
            do {
                let privateKey = Hex.decode("<Private key>")!
                let sender = "<Sender>"
                let recipient = "<Recipient>"
                let web3 = Web3.InfuraMainnetWeb3()
                let txCount = try web3.eth.getTransactionCount(address: EthereumAddress(sender))
                let gasPrice = try web3.eth.getGasPrice()
                let token = ERC20Token(erc20TokenContractAddress: "0x763186eB8d4856D536eD4478302971214FEbc6A9")
                let tx = EthereumCore.Transaction.Transfer(sender: sender,
                                                           recipient: recipient,
                                                           amount: 10,
                                                           nonce: txCount,
                                                           gasPrice: gasPrice,
                                                           gasLimit: 200000,
                                                           ethBalance: nil,
                                                           token: token)
                let signed = try tx.sign(privateKey: privateKey)
                let txString = String(signed.serializedTransactionHex.dropFirst(2))
                let txData = Hex.decode(txString)!
                _ = try web3.eth.sendRawTransaction(txData)
                promise.fulfill()
            } catch {
                XCTFail("Error: \(error)")
                promise.fulfill()
            }
        }
        wait(for: [promise], timeout: 30)
    }

}
