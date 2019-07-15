//
//  ViewController.swift
//  Examples
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import UIKit
import CryptoCore
import paytomat_crypto_core

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wordList = Mnemonic.Language.english.wordList
        print("let wordList = [")
        for (i, word) in wordList.enumerated() {
            if i == wordList.count - 1 {
                print("\t\"\(word)\"")
            } else {
                print("\t\"\(word)\",")
            }
        }
        print("]")
        if let keccak = CryptoCore.Crypto.keccak256(Data([0, 2, 4])) {
            print("__KECCAK \(keccak.count) \(Hex.encode(keccak))")
        }
        
        if let sha = CryptoCore.Crypto.sha256(Data([0, 2, 4])) {
            print("__SHA \(sha.count) \(Hex.encode(sha))")
        }
        
        if let decoded = Base58.decode("72k1xXWG59wUsYv7h2"),
            let string = String(bytes: decoded, encoding: .ascii) {
            print("__Base58 \(string)")
        }
        
    }


}

