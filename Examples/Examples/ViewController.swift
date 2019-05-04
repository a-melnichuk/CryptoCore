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
        print("__TEST1")
        CryptoCore.Crypto.testPrint()
        print("__TEST2")
        ptc_test_print()
        if let keccak = CryptoCore.Crypto.keccak256(Data([0, 2, 4])) {
            print("__KECCAK \(keccak.count) \(CryptoUtil.hex(fromData: keccak))")
        }
        
        if let sha = CryptoCore.Crypto.sha256(Data([0, 2, 4])) {
            print("__SHA \(sha.count) \(CryptoUtil.hex(fromData: sha))")
        }
        
        
    }


}

