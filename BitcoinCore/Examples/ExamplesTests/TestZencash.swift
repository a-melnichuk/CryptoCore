//
//  TestZencash.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 9/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import Foundation
import CryptoCore
import BitcoinCore

class TestZencash: XCTestCase {
    
    let network = Zencash()
    
    func testTransaction() {
        let network = Zencash()
        let mnemonic: Mnemonic = "company melt muscle vital emotion journey repeat chair elegant bench tiny crowd camera speed truth poet ability alone exact horse river test culture client"
        let seed = Seed(mnemonic: mnemonic)!
        
        let changePath = BIP32Path(purpose: .m44, coin: network.coin, account: 0, change: .change, addressIndex: 0)
        let rootPath = BIP32Path(purpose: .m44, coin: network.coin, account: 0, change: .external, addressIndex: 0)
        guard let rootPrivateKey = BitcoinPrivateKey(seed: seed),
            let privateKey = rootPrivateKey.derivedPrivateKey(path: changePath),
            let publicKey = privateKey.anyPublicKey(),
            let externalPrivateKey = rootPrivateKey.derivedPrivateKey(path: rootPath),
            let externalPublicKey = externalPrivateKey.anyPublicKey() else {
                XCTFail("\(#file).\(#function) transaction output generation failed")
                return
        }
        
        let utxo = UTXO(address: "znekWXBVxZXSNZ1jo6Y1SxGjmXUUYDxcE6c",
                        txId: Hex.decode("e127f18dc4c0650b9f22739bdd7c574e812bfd6d90ebfc96e8703cde1fe2d1a7")!,
                        value: 1000000,
                        outputIndex: 0,
                        subScript: Hex.decode("76a91495e644235fb94432ad42f4359dcab3e26b72e32388ac209632da3a85adfbe1f06d2675768c0750eb232b52bf7c93714cdc6409000000000325da08b4")!)
        
        let utxos: [UTXO] = [
            utxo
        ]
        
        let utxosKeyPairs: [UTXOKeyPair] = utxos.map {
            UTXOKeyPair(utxo: $0, privateKey: externalPrivateKey.raw, publicKey: externalPublicKey.raw)
        }
        
        let tx = BitcoinCore.Transaction.Transfer(network: network,
                                                  senderPublicKey: publicKey.raw,
                                                  recipientAddress: "znWHteo3Zzrc5EuP8STPXFYGVprJ7R69mCv",
                                                  fee: 10000,
                                                  amount: 2,
                                                  version: network.transactionVersion,
                                                  dust: 546,
                                                  blockInfo: BlockInfo(blockIndex: 580178, blockHash: Hex.decode("000000000434c4d63cbeae4e06bb2eb9a84c6a3ce1997955612863e64440bb11")!))
        do {
            let serialized = try tx.sign(utxoKeyPairs: utxosKeyPairs)
            
            XCTAssertEqual(Hex.encode(privateKey.raw), "7444b22be52f723210dd6230bdda632523f27df74efd6dd5136a777546c63fbe")
            XCTAssertEqual(Hex.encode(publicKey.raw), "024db2bd4ce399062da435a0fdad948c97b6254a5a57848a061b7c7436a38bcbfa")
            XCTAssertEqual(mnemonic.description, "company melt muscle vital emotion journey repeat chair elegant bench tiny crowd camera speed truth poet ability alone exact horse river test culture client")
            XCTAssertEqual(serialized.transactionHex, "0100000001a7d1e21fde3c70e896fceb906dfd2b814e577cdd9b73229f0b65c0c48df127e1000000006a47304402202981d5811adeda2b804ce2c9ab32bf98c458aefea7d8c5e9aa1364d21bb4ca5002206ab514a1b1c4eb7d2ca91a09d90fb9a5e311fe56b077aa221ab6735ebf808fbb0121024ee9aed673fd1141d83b524602a840b08317da7d5fbc8cc32303dfd7f4bcb959ffffffff0202000000000000003f76a914391c80cfa3f9864dd482592c1fe38f6ccf2b013688ac2011bb4044e6632861557999e13c6a4ca8b92ebb064eaebe3cd6c43404000000000352da08b42e1b0f00000000003f76a914578ac73cc42db1bac4372bb44a5ccd7524fe5fd588ac2011bb4044e6632861557999e13c6a4ca8b92ebb064eaebe3cd6c43404000000000352da08b400000000")
        } catch let error {
            XCTFail("\(#file).\(#function) transaction serialzation failed with error: \(error)")
            return
        }
    }
    
    func testP2PKH_2() {
        let address = "znnjppzJG7ajT7f6Vp1AD6SjgcXBVPA2E6c"
        guard let pubKeyHash = BitcoinCore.hash160(network: network, address: address) else {
            XCTFail("Unabled to create \(network) pubKeyHash")
            return
        }
        let blockHeight: Int32 = 142091
        let blockHash = Hex.decode("00000001cf4e27ce1dd8028408ed0a48edd445ba388170c9468ba0d42fff3052")!
        let blockInfo = BlockInfo(blockIndex: blockHeight, blockHash: blockHash)
        
        let script = network.buildP2PKHScript(pubKeyHash: pubKeyHash, blockInfo: blockInfo)!
        let expectedScriptHex = "76a914ed86236e297e70df7bb567f7f97312d2e4240aa588ac205230ff2fd4a08b46c9708138ba45d4ed480aed088402d81dce274ecf01000000030b2b02b4"
        XCTAssertEqual(Hex.encode(script), expectedScriptHex)
    }
    
    func testP2PKH() {
        let address = "znUovxhrE91tep6D7YtgSc3XJZoYQLVDwVn"
        guard let pubKeyHash = BitcoinCore.hash160(network: network, address: address) else {
            XCTFail("Unabled to create \(network) pubKeyHash")
            return
        }
        let blockHeight: Int32 = 384193
        let blockHash = Hex.decode("00000000243b36d24eb0e2f76a6549fa48f1c0aab3f09e02c1bacf75a27d736d")!
        let blockInfo = BlockInfo(blockIndex: blockHeight, blockHash: blockHash)
        
        let script = network.buildP2PKHScript(pubKeyHash: pubKeyHash, blockInfo: blockInfo)!
        let expectedScriptHex = "76a91428daa861e86d49694937c3ee6e637d50e8343e4b88ac206d737da275cfbac1029ef0b3aac0f148fa49656af7e2b04ed2363b240000000003c1dc05b4"
        XCTAssertEqual(Hex.encode(script), expectedScriptHex)
    }
    
    func testP2WPKH() {
        let address = "zszpcLB6C5B8QvfDbF2dYWXsrpac5DL9WRk"
        guard let pubKeyHash = BitcoinCore.hash160(network: network, address: address) else {
            XCTFail("Unabled to create \(network) pubKeyHash")
            return
        }
        XCTAssertEqual(Hex.encode(pubKeyHash), "df23c5eaba30b4d95798c5d5d0e2ecc2a3dc4ff2")
        
        let blockHeight: Int32 = 384590
        let blockHash = Hex.decode("00000000018fee313affacd114fc0695f497b9fe70d6cf6ff731870b3eefbf21")!
        let blockInfo = BlockInfo(blockIndex: blockHeight, blockHash: blockHash)
        
        let script = network.buildP2WPKHScript(pubKeyHash: pubKeyHash, blockInfo: blockInfo)!
        let expectedScriptHex = "a914df23c5eaba30b4d95798c5d5d0e2ecc2a3dc4ff2872021bfef3e0b8731f76fcfd670feb997f49506fc14d1acff3a31ee8f0100000000034ede05b4"
        XCTAssertEqual(Hex.encode(script), expectedScriptHex)
    }
}
