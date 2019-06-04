//
//  ViewController.swift
//  Examples
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import UIKit
import WavesCore
import CryptoCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("__TEST: \(Crypto.Waves.testInt()) \(Crypto.Waves.testInt2())")
        print("__TEST_SHA: \(Crypto.Waves.testSha())")
        print("__TEST_SHA2: \(Crypto.Waves.testSha2())")
        print("__TEST_SHA3: \(Crypto.Waves.testSha3())")

    }


}

