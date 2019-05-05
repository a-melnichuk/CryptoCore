//
//  CryptoTests.swift
//  CryptoCoreTests
//
//  Created by Alex Melnichuk on 5/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
@testable import CryptoCore

class CryptoTests: XCTestCase {

    func testKeccak() {
        let hex = "6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77"
        guard let data = Crypto.data(fromHex: hex) else {
            XCTFail("Invalid hex string")
            return
        }
        guard let keccak = Crypto.keccak256(data) else {
            XCTFail("Unable to hash with keccak")
            return
        }
        XCTAssertEqual(keccak.count, 32)
        XCTAssertEqual(Crypto.hex(fromData: keccak), "c82180a0c14bbdb9ced8e83cd9d07d75778a5e5806e0a073d85f87229de6b82d")
    }
    
    func testBlake2b() {
        let data = Crypto.data(fromHex:"6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77")!
        guard let blake2b = Crypto.blake2b256(data) else {
            XCTFail("Unable to hash with blake")
            return
        }
        XCTAssertEqual(blake2b.count, 32)
        XCTAssertEqual(Crypto.hex(fromData: blake2b), "c14c10e0b1be5bdea8a1ad0acb3192533b27fce565ce75e51761cc04ab2226a0")
    }
   
    func testSha() {
        let data = Crypto.data(fromHex:"6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77")!
        guard let sha = Crypto.sha256(data) else {
            XCTFail("Unable to hash with blake")
            return
        }
        XCTAssertEqual(sha.count, 32)
        XCTAssertEqual(Crypto.hex(fromData: sha), "fb2ab780dba99bb4c6ef46f8fde1315a80c42025765c74578dec95c48cdd5821")
    }
    
    func testRipemd() {
        let data = Crypto.data(fromHex:"6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77")!
        
        guard let ripemd160 = Crypto.ripemd160(data) else {
            XCTFail("Unable to hash with ripemd")
            return
        }
        XCTAssertEqual(ripemd160.count, 20)
        XCTAssertEqual(Crypto.hex(fromData: ripemd160), "6de005387ee1718d2f8cac56b825b5446acc3b7b")
        
        guard let sha256ripemd160 = Crypto.sha256ripemd160(data) else {
            XCTFail("Unable to hash with sha256ripemd160")
            return
        }
        XCTAssertEqual(sha256ripemd160.count, 20)
        XCTAssertEqual(Crypto.hex(fromData: sha256ripemd160), "4c7ba5753afce550514e838cab66d62681766787")
    }
    
    func testHmac() {
        let data = Crypto.data(fromHex:"6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77")!
        let key = Crypto.data(fromHex: "c1b772ac07f2b5c973a4f79c6736449a6de3552bf660a1871619e4ac0518fd3f")!
        
        guard let hmacsha512 = Crypto.hmacsha512(data, key: key) else {
            XCTFail("Unable to hash with ripemd")
            return
        }
        XCTAssertEqual(hmacsha512.count, 64)
        XCTAssertEqual(Crypto.hex(fromData: hmacsha512), "c912c37a5435b1a0cfe8f2dfd69a71a6a9b93575f5e739fa3bcc8b82045463cac6c744ec4618f54cecfaf08c1e75f6c64a8c6baa277ba516c988703e08418df2")
    }
}
