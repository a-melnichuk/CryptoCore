//
//  TestDerivedKeyCreationConsistency.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 6/25/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import CryptoCore

class TestDerivedKeyCreationConsistency: XCTestCase {
    
    struct DerivedKeyCreationModel: Codable {
        let mnemonic: [String]
        let seed: String
    }
    
    func testDerivedKeyCreation() {
        do {
            let path = Bundle(for: type(of: self)).url(forResource: "derived_key_creation", withExtension: "txt")!
            let data = try Data(contentsOf: path)
            let models = try JSONDecoder().decode([DerivedKeyCreationModel].self, from: data)
            
            for (i, model) in models.enumerated() {
                let percent = String(format: "%.2f%%", Double(i) / Double(models.count) * 100)
                print("\(#function) \(percent)")
                
                guard let seed = Mnemonic.seed(mnemonic: model.mnemonic) else {
                    XCTFail("Unable to generate seed phrase")
                    return
                }
                let seedHex = Crypto.hex(fromData: seed)
                XCTAssertEqual(seedHex, model.seed)
            }
            
        } catch {
            XCTFail("Error: \(error)")
        }
    }
}
