//
//  TestAddressGeneration.swift
//  ExamplesTests
//
//  Created by Alex Melnichuk on 7/11/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import XCTest
import CryptoCore
import BitcoinCore

class TestAddressGeneration: XCTestCase {
    struct AddressInfo: Codable {
        let mnemonic: String
        let path: String
        let publicKey: String
        let privateKey: String
        let address: String
    }
    
    struct Info {
        let fileName: String
        let network: Network
    }
    
    let infos: [Info] = [
       // Info(fileName: "zen", network: Zencash()),
        //Info(fileName: "ltc", network: Litecoin()),
        Info(fileName: "btc", network: Bitcoin()),
        Info(fileName: "dash", network: Dash())
    ]

    func testBitcoinAndAltcoinsGeneration() {
        var queues = [DispatchQueue]()
        var expectations = [XCTestExpectation]()
        
        (0..<infos.count).forEach { i in
            let networkType = type(of: infos[i].network)
            let description = "\(networkType)\(i)"
            queues.append(DispatchQueue(label: description, qos: .userInitiated, target: nil))
            expectations.append(XCTestExpectation(description: description))
        }
        
        for coinIndex in 0..<infos.count {
            let info = infos[coinIndex]
            let fileName = info.fileName
            let network = info.network
            let networkType = type(of: network)
            let expectation = expectations[coinIndex]
            let queue = queues[coinIndex]
            queue.async {
                do {
                    let path = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "txt")!
                    let string = try String(contentsOf: path)
                    let dataModels = string
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .components(separatedBy: .newlines)
                        .map { Data($0.utf8) }
                    
                    for (i, data) in dataModels.enumerated() {
                        if data.isEmpty {
                            continue
                        }
                        let model = try JSONDecoder().decode(AddressInfo.self, from: data)
                        let mnemonic = Mnemonic(string: model.mnemonic)
                        guard let seed = Seed(mnemonic: mnemonic) else {
                            XCTFail("Unable to create seed from mnemonic: \(model.mnemonic)")
                            return
                        }
                        guard let masterPrivateKey = HDPrivateKey(seed: seed) else {
                            XCTFail("Unable to create root private key from seed for: \(model)")
                            return
                        }
                        guard let privateKey = masterPrivateKey.derived(for: model.path) else {
                            XCTFail("Unable to derive private key from root private key \(String(describing: Hex.encode(masterPrivateKey.raw))) for: \(model.path)")
                            return
                        }
                        let privateKeyString = WIF.encode(privateKey.raw, version: network.privatekey, compressed: network.hasCompressedWIFKeys)
                        guard let publicKey = BitcoinCore.publicKey(privateKey: privateKey.raw) else {
                            XCTFail("Unable to create public key from: \(String(describing: privateKeyString))")
                            return
                        }
                        
                        guard let address = BitcoinCore.address(publicKey: publicKey, network: network) else {
                            XCTFail("Unable to create address from: \(Hex.encode(publicKey))")
                            return
                        }
                        guard address == model.address else {
                            XCTFail("\(networkType) Address mismatch: \(address) != \(model.address), mnemonic: \(mnemonic.description), path: \(model.path)")
                            return
                        }
                        XCTAssertEqual(address, model.address)
                        let percent = Double(i) / Double(dataModels.count) * 100
                        print("\(#function) \(networkType): \(String(format: "%.2f%%", percent)) - \(address)")
                    }
                    expectation.fulfill()
                } catch {
                    XCTFail("Error when parsing address models: \(error)")
                }
            }
            
        }
        
        wait(for: expectations, timeout: TimeInterval.greatestFiniteMagnitude)
    }
}
