//
//  CryptoCoreTests.swift
//  CryptoCoreTests
//
//  Created by Alex Melnichuk on 5/1/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
@testable import CryptoCore
@testable import paytomat_crypto_core

class CryptoCoreTests: XCTestCase {

    func testKeccak() {
        let hex = "6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77"
        guard let data = CryptoUtil.data(fromHex: hex) else {
            XCTFail("Invalid hex string")
            return
        }
        guard let keccak = Crypto.keccak256(data) else {
            XCTFail("Unable to hash with keccak")
            return
        }
        XCTAssertEqual(keccak.count, 32)
        XCTAssertEqual(CryptoUtil.hex(fromData: keccak), "c82180a0c14bbdb9ced8e83cd9d07d75778a5e5806e0a073d85f87229de6b82d")
    }
    
    func testBlake2b() {
        let data = CryptoUtil.data(fromHex:"6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77")!
        guard let blake2b = Crypto.blake2b256(data) else {
            XCTFail("Unable to hash with blake")
            return
        }
        XCTAssertEqual(blake2b.count, 32)
        XCTAssertEqual(CryptoUtil.hex(fromData: blake2b), "c14c10e0b1be5bdea8a1ad0acb3192533b27fce565ce75e51761cc04ab2226a0")
    }
   
    func testExample() {
        XCTAssertEqual(Crypto.testInt(), 4)
    }
    
    func testBlakePerforance() {
        measure {
            (0..<50).forEach { _ in testBlake2b() }
        }
    }
}
