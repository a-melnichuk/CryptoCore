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
        let data = Crypto.data(fromHex:"6f2072656e64657220747261636b20736561726368206b696420766963746f7279207368656c6c206162757365206d65726765207175616c69747920726f79616c20636c69702075676c79206c797269637320726f756768206e6174696f6e2068756765207374727567676c6520686172642065786572636973652062616c6c2070726f766964652064757479206e6f77")!
        let hash = Crypto.Waves.secureHash(data)!
        
        print("__TEST: \(Crypto.hex(fromData: hash))")
       
    }


}

