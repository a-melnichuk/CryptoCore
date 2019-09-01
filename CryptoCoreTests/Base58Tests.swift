//
//  TestBase58.swift
//  CryptoCoreTests
//
//  Created by Alex Melnichuk on 5/5/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
@testable import CryptoCore

class TestBase58: XCTestCase {
    
    func testBase58Check() {
        let validAddress0 = "tz1WitABJe4GvjVrmb2oXTSQ97eECzcgSmVf"
        let validAddress1 = "znXyidcTkHL4dqDhzCEStEn51gAWBzbBrhP"
        let validAddress2 = "1rDFxbsnofFNo5r19pudcxYxup2DZULno"
        let invalidAddress0 = "tz1WitABJe4GvjVrmb2oXTSQ97eECzcgSmVb"
        let invalidAddress1 = "znXyidcTkHL4dqDhzCEStEn51gAWBzbBrhz"
        let invalidAddress2 = "1rDFxbsnofFNo5r19pudcxYxup2DZULne"
        
        XCTAssertTrue(Base58.check(string: validAddress0, version: [6, 161, 159]))
        XCTAssertFalse(Base58.check(string: invalidAddress0, version: [6, 161, 159]))
        XCTAssertFalse(Base58.check(string: validAddress0, version: [0, 161, 159]))
        
        XCTAssertTrue(Base58.check(string: validAddress1, version: [32, 137]))
        XCTAssertFalse(Base58.check(string: invalidAddress1, version: [32, 137]))
        XCTAssertFalse(Base58.check(string: validAddress1, version: [31, 137]))
        
        XCTAssertTrue(Base58.check(string: validAddress2, version: [0]))
        XCTAssertFalse(Base58.check(string: invalidAddress2, version: [0]))
        XCTAssertFalse(Base58.check(string: validAddress2, version: [1]))
    }
    
    func testBase58() {
        let stirng = "Hello, world!"
        let ascii = stirng.data(using: .ascii)!
        
        guard let encoded = Base58.encode(ascii) else {
            XCTFail("Unable to encode string")
            return
        }
        XCTAssertEqual(encoded, "72k1xXWG59wUsYv7h2")
        
        guard let bytes = Base58.decode(encoded),
            let decoded = String(bytes: bytes, encoding: .ascii) else {
            XCTFail("Unable to decode base58 string")
            return
        }
        XCTAssertEqual(decoded, stirng)
    }
    
    func testBase58CheckWif() {
        let wif = "L5cTdc7q36W1Mjmvew9ysubhxtX7GfuXPQkzit9ppmfAoFkBTKZk"
        XCTAssertTrue(Base58.check(string: wif, version: [0x80]))
        guard let decoded = Base58.check(decode: wif, version: [0x80]) else {
            XCTFail("Unable to decode key")
            return
        }
        let raw = decoded
        XCTAssertEqual(Hex.encode(raw), "fa66f475ad1f0bc09f17c7e3d7f2d4a2cf9b7f41ee173455988456b41bbedef401")
        guard let encoded = Base58.check(encode: raw, version: [0x80]) else {
            XCTFail("Unable to encode key")
            return
        }
        XCTAssertEqual(encoded, wif)
    }
    
    func testUncompressedWIF() {
        let wif = "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"
        guard let decoded = WIF.decode(wif, version: [0x80], compressed: false) else {
            XCTFail("Unable to decode WIF")
            return
        }
        XCTAssertEqual(Hex.encode(decoded).uppercased(), "0C28FCA386C7A227600B2FE50B7CAE11EC86D3BF1FBE471BE89827E19D72AA1D")
        let encoded = WIF.encode(decoded, version: [0x80], compressed: false)
        XCTAssertEqual(encoded, wif)
    }
    
    func testCompressedWIF() {
        let wif = "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvYM7zbMx"
        guard let decoded = WIF.decode(wif, version: [0x80], compressed: true) else {
            XCTFail("Unable to decode WIF")
            return
        }
        XCTAssertEqual(Hex.encode(decoded).uppercased(), "0C28FCA386C7A227600B2FE50B7CAE11EC86D3BF1FBE471BE89827E19D72AA")
        let encoded = WIF.encode(decoded, version: [0x80], compressed: true)
        XCTAssertEqual(encoded, wif)
    }
}
