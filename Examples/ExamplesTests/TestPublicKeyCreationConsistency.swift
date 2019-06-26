//
//  TestPublicKeyCreationConsistency.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 6/25/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import CryptoCore

class TestPublicKeyCreationConsistency: XCTestCase {

    struct PublicKeyCreationModel: Codable {
        let privateKey: String
        let compressed: Bool
        let publicKey: String
    }

    func testPublicKeyCreationConsistency() {
        do {
            let path = Bundle(for: type(of: self)).url(forResource: "public_key_creation", withExtension: "txt")!
            let data = try Data(contentsOf: path)
            let models = try JSONDecoder().decode([PublicKeyCreationModel].self, from: data)
            
            for (i, model) in models.enumerated() {
                let percent = String(format: "%.2f%%", Double(i) / Double(models.count) * 100)
                print("\(#function) \(percent)")
                guard let privateKey = Crypto.data(fromHex: model.privateKey) else {
                    XCTFail("Unable to decode private key")
                    return
                }
                guard let publicKey = Crypto.Key.publicKey(from: privateKey, compressed: model.compressed) else {
                    XCTFail("Unable to create a public key")
                    return
                }
                let publicKeyHex = Crypto.hex(fromData: publicKey)
                XCTAssertEqual(publicKeyHex, model.publicKey)
            }
            
        } catch {
            XCTFail("Error: \(error)")
        }
    }
}
