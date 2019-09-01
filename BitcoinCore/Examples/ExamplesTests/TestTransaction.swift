//
//  TestTransaction.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 7/14/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import CryptoCore
import BitcoinCore

class TestTransaction: XCTestCase {
    
    func testLTCTransaction() {
        let network = Litecoin()
        let mnemonic: Mnemonic = "company melt muscle vital emotion journey repeat chair elegant bench tiny crowd camera speed truth poet ability alone exact horse river test culture client"
        let seed = Seed(mnemonic: mnemonic)!
        
        let recipientMnemonic: Mnemonic = "base filter item frog canyon raccoon kiwi slot twenty card side foil brother thrive reject suspect chest vapor citizen version various matter priority tackle"
        let recipientAddress = "LdxVSrhY9n6UzEXQypEi1qBZBuiU1foqKy"
      
        let changePath = BIP32Path(purpose: .m44, coin: network.coin, account: 0, change: .change, addressIndex: 0)
        let rootPath = BIP32Path(purpose: .m44, coin: network.coin, account: 0, change: .external, addressIndex: 0)
        guard let rootPrivateKey = BitcoinPrivateKey(seed: seed),
            let privateKey = rootPrivateKey.derivedPrivateKey(path: changePath),
            let publicKey = privateKey.anyPublicKey(),
            let externalPrivateKey = rootPrivateKey.derivedPrivateKey(path: rootPath),
            let externalPublicKey = externalPrivateKey.anyPublicKey() else {
                XCTFail("\(#file).\(#function) transaction output generation failed")
                return
        }
    
        let utxo = UTXO(address: "LfseFCxaErQdM5thXBzWKpdiEPrm2vziGr",
                        txHex: "f8e1fc136f2a821113faa771c67788544c5970738d34f27ef30fd62a3aa75fd7",
                        value: 519900000,
                        outputIndex: 4,
                        subScriptHex: "76a914e2834837c89a20b1f250187d02ef7262597d37a588ac")
        
        let utxos: [UTXO] = [
            utxo
        ]
        
        let utxosKeyPairs: [UTXOKeyPair] = utxos.map {
            UTXOKeyPair(utxo: $0, privateKey: externalPrivateKey.raw, publicKey: externalPublicKey.raw)
        }

        let tx = BitcoinCore.Transaction.Transfer(network: network,
                                                  senderPublicKey: publicKey.raw,
                                                  recipientAddress: recipientAddress,
                                                  fee: 300,
                                                  amount: 200000000,
                                                  version: 1,
                                                  dust: 546,
                                                  blockInfo: BlockInfo(blockIndex: 0, blockHash: Data()))
        do {
            let serialized = try tx.sign(utxoKeyPairs: utxosKeyPairs)
            XCTAssertEqual(Hex.encode(privateKey.raw), "2fcbcca36ff454362fb1343a33bfd36f739ec5af7a84a3e32f37c4eb48c6f3a0")
            XCTAssertEqual(Hex.encode(publicKey.raw), "0391ad571f2fcf1f935c6777b742fe46165ca8a3908c3a293fc76e2997c20cfd43")
            XCTAssertEqual(mnemonic.description, "company melt muscle vital emotion journey repeat chair elegant bench tiny crowd camera speed truth poet ability alone exact horse river test culture client")
            XCTAssertEqual(recipientMnemonic.description, "base filter item frog canyon raccoon kiwi slot twenty card side foil brother thrive reject suspect chest vapor citizen version various matter priority tackle")
            XCTAssertEqual(serialized.transactionHex, "0100000001d75fa73a2ad60ff37ef2348d7370594c548877c671a7fa1311822a6f13fce1f8040000006b483045022100d0dce939353ef62a83e0659dae375bc5420005cbef04b776a247b9b3e48923e60220176b88e70143dc9f2fda6f0fcc9dd0103664c5f0970739e9e7fb3a361e6cb428012103830dfaab60c49d1c6486a1d458a2e03fc8012d687ac20ee4ba8985e2c99dcea9ffffffff0200c2eb0b000000001976a914cd7dc3e44b6d747f01e0d5acc8879cc5c39d39cd88acb4411013000000001976a91454c79de17fe845fcb65c104f629f08b29dbe0d3988ac00000000")
        } catch let error {
            XCTFail("\(#file).\(#function) transaction serialzation failed with error: \(error)")
            return
        }
    }
}
