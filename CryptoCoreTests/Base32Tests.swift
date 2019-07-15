//
//  Base32Tests.swift
//  CryptoCoreTests
//
//  Created by Alex Melnichuk on 6/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
@testable import CryptoCore

class TestBase32: XCTestCase {
    
    func testBase32() {
        let stirng = "Hello, world!"
        let encoding: String.Encoding = .utf8
        let stringData = stirng.data(using: encoding)!
        
        guard let encoded = Base32.encode(stringData) else {
            XCTFail("Unable to encode string")
            return
        }
        
        XCTAssertEqual("JBSWY3DPFQQHO33SNRSCC", encoded)
        
        guard let bytes = Base32.decode(encoded),
               let decoded = String(data: bytes, encoding: encoding) else {
                XCTFail("Unable to decode base32 string")
                return
        }
        XCTAssertEqual(decoded, stirng)
    }
}
