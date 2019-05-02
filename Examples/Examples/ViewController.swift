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
        CryptoCore.testPrint()
        print("__TEST2")
        ptc_test_print()
        print("__INT1 \(CryptoCore.testInt())")
        print("__INT2 \(ptc_test_int())")
        
    }


}

