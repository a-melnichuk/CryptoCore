//
//  TestAddressGeneration.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 7/11/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import CryptoCore
import TRONCore

class TestAddressGeneration: XCTestCase {
    struct AddressInfo: Codable {
        let mnemonic: String
        let path: String
        let publicKey: String
        let privateKey: String
        let address: String
    }
    
    func testAddressValidation() {
        let isValid = "TRzd6SDUZMGKcJZXc5hgG5fRBhXAEYXADS".isValidTRONAddress
        XCTAssertTrue(isValid)
    }
    
//    func testAddressGeneration() {
//        do {
//            let path = Bundle(for: type(of: self)).url(forResource: "trx", withExtension: "txt")!
//            let string = try String(contentsOf: path)
//            let dataModels = string.components(separatedBy: .newlines)
//                .map { Data($0.utf8) }
//            for (i, data) in dataModels.enumerated() {
//                if data.isEmpty {
//                    continue
//                }
//                let model = try JSONDecoder().decode(AddressInfo.self, from: data)
//                let mnemonic = Mnemonic(string: model.mnemonic)
//                guard let seed = Seed(mnemonic: mnemonic) else {
//                    XCTFail("Unable to create seed from mnemonic: \(model.mnemonic)")
//                    return
//                }
//                guard let masterPrivateKey = HDPrivateKey(seed: seed) else {
//                    XCTFail("Unable to create root private key from seed for: \(model)")
//                    return
//                }
//                guard let privateKey = masterPrivateKey.derived(for: model.path) else {
//                    XCTFail("Unable to derive private key from root private key \(String(describing: Hex.encode(masterPrivateKey.raw))) for: \(model.path)")
//                    return
//                }
//                let privateKeyString = "0x\(Hex.encode(privateKey.raw))"
//                XCTAssertEqual(privateKeyString, model.privateKey)
//                guard let publicKey = TRONCore.publicKey(privateKey: privateKey.raw) else {
//                    XCTFail("Unable to create public key from: \(privateKeyString)")
//                    return
//                }
//                let publicKeyString = "0x\(Hex.encode(publicKey))"
//                XCTAssertEqual(publicKeyString, model.publicKey)
//                guard let address = TRONCore.address(publicKey: publicKey) else {
//                    XCTFail("Unable to create address from: \(publicKeyString)")
//                    return
//                }
//                XCTAssertEqual(address, model.address)
//                let percent = Double(i) / Double(dataModels.count) * 100
//                print("\(#function): \(String(format: "%.2f%%", percent)) - \(address)")
//            }
//        } catch {
//            XCTFail("Error when parsing address models: \(error)")
//        }
//    }
}
