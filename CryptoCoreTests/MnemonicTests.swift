//
//  MnemonicTests.swift
//  CryptoCoreTests
//
//  Created by Alex Melnichuk on 6/26/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import CryptoCore

class MnemonicTests: XCTestCase {
    
    func testMnemonicGeneration() {
        XCTAssertNoThrow(try Mnemonic.Strength.allCases.forEach { strength in
            XCTAssertNoThrow(try Mnemonic.generate(strength: strength, language: .english))
        })
    }
    
    func testValidMnemonicValidation() {
        let validMnemonicString1 = "sweet ice joke silly empower proof entire weird blame ordinary gloom swamp"
        let validMnemonicString2 = "spend rail close toy fade artefact blind february scissors glance art brick they resource man"
        let validMnemonicString3 = "genius egg sunny actual page hole warrior champion city elbow kick wood duck truly pencil police ivory auction"
        let validMnemonicString4 = "cream crumble left pepper lend better resist raw illegal use squirrel supply column tumble quote clog poet curtain brand army mixture"
        let validMnemonicString5 = "response regular scorpion short grace hip cute race exact owner trap surface repeat drill stadium huge furnace expand actress reunion coffee index middle human"
        
        let validMnemonicStrings: [String] = [
            validMnemonicString1,
            validMnemonicString2,
            validMnemonicString3,
            validMnemonicString4,
            validMnemonicString5
        ]
        
        for mnemonicString in validMnemonicStrings {
            let mnemonic = Mnemonic(string: mnemonicString)
            XCTAssertTrue(Mnemonic.valid(mnemoic: mnemonic.array, strength: mnemonic.strength, language: mnemonic.language))
        }
    }
    
    func testInvalidMnemonicValidation() {
        // invalid word inside mnemonic
        let invalidMnemonicString1 = "a ice joke silly empower proof entire weird blame ordinary gloom swamp"
        // empty
        let invalidMnemonicString2 = ""
        // bad entropy
        let invalidMnemonicString3 = "genius genius genius genius genius genius genius genius genius genius genius genius genius genius genius genius genius genius"
        // invalid word count
        let invalidMnemonicString4 = "crumble left pepper lend better resist raw illegal use squirrel supply column tumble quote clog poet curtain brand army mixture"
        // blank
        let invalidMnemonicString5 = "      "
        let invalidMnemonicStrings: [String] = [
            invalidMnemonicString1,
            invalidMnemonicString2,
            invalidMnemonicString3,
            invalidMnemonicString4,
            invalidMnemonicString5
        ]
        
        for mnemonicString in invalidMnemonicStrings {
            let mnemonic = mnemonicString.components(separatedBy: " ")
            let strength = Mnemonic.Strength(rawValue: mnemonic.count) ?? .default
            XCTAssertFalse(Mnemonic.valid(mnemoic: mnemonic, strength: strength, language: .english), "Mnemonic is valid: \(mnemonicString)")
        }
    }
    
    func testMnemonicGenerationConsistency() {
        let strengthLevels: [Mnemonic.Strength] = (0..<10000).map { _ in
            return Mnemonic.Strength.allCases.randomElement()!
        }
        for (i, strength) in strengthLevels.enumerated() {
            let percent = String(format: "%.2f%%", Double(i) / Double(strengthLevels.count) * 100)
            print("\(#function): \(percent)")
            XCTAssertNoThrow(try Mnemonic.generate(strength: strength, language: .english))
        }
    }
}
