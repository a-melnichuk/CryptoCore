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
