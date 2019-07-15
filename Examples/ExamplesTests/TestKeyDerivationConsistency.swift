//
//  TestKeyDerivationConsistency.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 6/25/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import CryptoCore

class TestKeyDerivationConsistency: XCTestCase {

    struct KeyDerivationCreationModel: Codable {
        let mnemonic: [String]
        let seed: String
        let rootPrivateKey: String
        let path: String
        let derivedPrivateKey: String
        let compressed: Bool
        let publicKey: String
    }
    
    func testKeyCreationFromSeed() {
        let seedData = Hex.decode("79b815bc4737394cd39dfecdc494988886b0297ea22f285a8013da2ab52596c205098a238540e2ec60ad0cfbb3112c96954b867e8ef5da047811bca0ac321b42")!
        let seed = Seed(seedData)
        let privateKey = HDPrivateKey(seed: seed)!
        XCTAssertEqual(Hex.encode(privateKey.raw), "5dae94d797fa5d36f4bb145fed4cb79c5bcc1b2fb90b9d9170b6f96f8b6edd64")
    }
    
    func testKeyDerivationConsistency() {
        do {
            let path = Bundle(for: type(of: self)).url(forResource: "key_derivation", withExtension: "txt")!
            let data = try Data(contentsOf: path)
            let models = try JSONDecoder().decode([KeyDerivationCreationModel].self, from: data)
            
            for (i, model) in models.enumerated() {
                let percent = String(format: "%.2f%%", Double(i) / Double(models.count) * 100)
                print("\(#function) \(percent)")
                
                let mnemonic = Mnemonic(model.mnemonic)
                guard let seed = Seed(mnemonic: mnemonic) else {
                    XCTFail("Unable to generate seed phrase")
                    return
                }
                
                XCTAssertEqual(Hex.encode(seed.raw), model.seed, "Seed mismatch")
                
                guard let privateKey = HDPrivateKey(seed: seed) else {
                    XCTFail("Unable to create a private key from seed")
                    return
                }
                XCTAssertEqual(Hex.encode(privateKey.raw), model.rootPrivateKey, "Root private key mismatch")
                guard let derivedKey = privateKey.derived(for: model.path) else {
                    XCTFail("Unable to derive a private key for path: \(model.path)")
                    return
                }
                XCTAssertEqual(Hex.encode(derivedKey.raw), model.derivedPrivateKey, "Derived key mismatch")
                
                guard let publicKey = Crypto.Key.publicKey(from: derivedKey.raw, compressed: model.compressed)  else {
                    XCTFail("Unable to create a public key")
                    return
                }
                
                XCTAssertEqual(Hex.encode(publicKey), model.publicKey)
            }
            
        } catch {
            XCTFail("Error: \(error)")
        }
    }
}
