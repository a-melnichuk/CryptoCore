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
        print("__TEST: \(WavesCrypto.testInt()) \(WavesCrypto.testInt2())")
        print("__TEST_SHA: \(WavesCrypto.testSha())")
        print("__TEST_SHA2: \(WavesCrypto.testSha2())")
        print("__TEST_SHA3: \(WavesCrypto.testSha3())")
        
        // Do any additional setup after loading the view.
    }


}

