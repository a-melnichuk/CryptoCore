//
//  WavesCoreTests.swift
//  WavesCoreTests
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
@testable import WavesCore
@testable import CryptoCore

class WavesCoreTests: XCTestCase {

    func testInt() {
        XCTAssertEqual(Crypto.Waves.testInt(), 5)
    }
    
    func testSha() {
        XCTAssertEqual(Crypto.Waves.testSha(), "fb2ab780dba99bb4c6ef46f8fde1315a80c42025765c74578dec95c48cdd5821")
    }
}
