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
        
        Crypto.Waves.secure
        
        print("__TEST: \(Cry) \(Crypto.Waves.testInt2())")
       
    }


}

