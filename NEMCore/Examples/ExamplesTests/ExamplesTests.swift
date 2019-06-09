//
//  ExamplesTests.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
@testable import Examples
@testable import CryptoCore
@testable import NEMCore

class ExamplesTests: XCTestCase {

    let expectedPrivateKeyHex = "a3786a75fe252391738a19678bc883d97cd1483516bbc78e5d74ba7691886d17"
    let expectedPublicKeyHex = "07aa2cb628bd2109d1b8db21d8f3c35a4888c715fb8d37cee72037a70b294b1f"

    func testXEMTransactionSerialization() {
        var privateKey = Crypto.data(fromHex: expectedPrivateKeyHex)!
        let timestamp: Int64 = 1526573983372

        let transfer = NEMCore.Transfer(amount: 100000000,
                                        recipient: "NBZMQO7ZPBYNBDUR7F75MAKA2S3DHDCIFG775N3D",
                                        message: nil,
                                        mosaics: [],
                                        balance: 900000000)
        let tx = NEMCore.Transaction(version: 1,
                                     timestamp: timestamp,
                                     timeOffset: 0,
                                     deadline: nil,
                                     networkByte: NEMCore.mainnetNetworkByte,
                                     transaction: transfer)
        do {
            let signed = try tx.sign(privateKey: &privateKey)
            XCTAssertEqual(signed.data, "01010000010000689e69e6052000000007aa2cb628bd2109d1b8db21d8f3c35a4888c715fb8d37cee72037a70b294b1fd012130000000000febde605280000004e425a4d514f375a5042594e42445552374637354d414b41325333444844434946473737354e334400e1f5050000000000000000")
            XCTAssertEqual(signed.signature, "5164ef640debed968eb89f348d980f8c7e2a54f148b8b256fd4613ece7ee4adced4dede2996cea7b237ef007066f8fab9a776a94ae669576bac1a68230dfcb0e")
        } catch {
            XCTFail("Transaction signature failed: \(error)")
        }
    }

    func testXEMMosaicTransactionSerialization() {
        var privateKey = Crypto.data(fromHex: "1359e91d4769256b5b9435f3dfd47eb406a224ffdc7dea0ab8569edcee0932be")!
        
        let recipient = "NBGL4N-2HLQ3D-AJP6DV-TSYV7S-3EIM6G-TIFD52-6LJ7"
        let amount: UInt64 = 1000000
        let timestamp: Int64 = 1548616705082
        let deadline: Int64 = 1548638305082
        let timeOffset: Int64 = 918

        let mosaic = NEMCore.Transfer.Mosaic(namespace: "odessa",
                                             mosaic: "mama",
                                             quantity: 1,
                                             supply: 5555555,
                                             divisibility: 0)
        let transfer = NEMCore.Transfer(amount: amount,
                                        recipient: recipient,
                                        message: nil,
                                        mosaics: [mosaic],
                                        balance: nil)
        let tx = NEMCore.Transaction(version: 2,
                                     timestamp: timestamp,
                                     timeOffset: timeOffset,
                                     deadline: deadline,
                                     networkByte: NEMCore.mainnetNetworkByte,
                                     transaction: transfer)
        do {
            let signed = try tx.sign(privateKey: &privateKey)
            XCTAssertEqual(signed.data, "010100000200006801c2360720000000b7369bf2c30181662cda2ae02cd76b5ddaa78708202bf5f988aa7ca230c2af7050c300000000000061163707280000004e42474c344e32484c513344414a503644565453595637533345494d3647544946443532364c4a3740420f000000000000000000010000001e00000012000000060000006f6465737361040000006d616d610100000000000000")
            XCTAssertEqual(signed.signature, "e2e6e2462bdace15d607456d8c9c416df9b4d11a27ea5e0f91023bc74da0b587a0d1acd70b3d40e106afc13e85f896a42bc33534cb28ebc26b272147d67d8900")
        } catch {
            XCTFail("tx Serialization failed with error: \(error)")
        }
    }
    
    func testAddressGeneration() {

        let privateKey = Crypto.data(fromHex: expectedPrivateKeyHex)!
        
        guard let publicKey = NEMCore.publicKey(privateKey: privateKey) else {
            XCTFail("Unable to generate public key")
            return
        }
        
        XCTAssertEqual(Crypto.hex(fromData: publicKey), "07aa2cb628bd2109d1b8db21d8f3c35a4888c715fb8d37cee72037a70b294b1f")

        guard let address = NEMCore.address(publicKey: publicKey) else {
            XCTFail("Unable to generate address")
            return
        }
        
        XCTAssertEqual(address, "NAIKOGSJDNQI5WKYLGDLUR3XXLSDGKMB6DERDBYR")

        let normalizedAddress = NEMCore.normalize(address: address)
        XCTAssertEqual(normalizedAddress, "NAIKOG-SJDNQI-5WKYLG-DLUR3X-XLSDGK-MB6DER-DBYR")

        let denormalizedAddress = NEMCore.denormalize(address: normalizedAddress)
        XCTAssertEqual(denormalizedAddress, address)

        let positiveValidation = NEMCore.valid(address: address)
        XCTAssertTrue(positiveValidation)

        let positiveValidation2 = NEMCore.valid(address: "-" + address + "-")
        XCTAssertTrue(positiveValidation2)

        let negativeValidation = NEMCore.valid(address: "NAIKOGSJDNQI5WKYLGDLUR3XXLSDGKMB6DERDBYP")
        XCTAssertFalse(negativeValidation)
    }
  
}
