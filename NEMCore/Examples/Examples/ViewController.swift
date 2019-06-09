//
//  ViewController.swift
//  Examples
//
//  Created by Alex Melnichuk on 5/6/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import UIKit
import NEMCore
import CryptoCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let privateKey = Crypto.data(fromHex: "a3786a75fe252391738a19678bc883d97cd1483516bbc78e5d74ba7691886d17")!
        guard let publicKey = NEMCore.publicKey(privateKey: privateKey) else {
            print("Unable to generate public key")
            return
        }
        
        print(Crypto.hex(fromData: publicKey))
        
        guard let address = NEMCore.address(publicKey: publicKey) else {
            print("Unable to generate address")
            return
        }
        
        print(address)
        
        let normalizedAddress = NEMCore.normalize(address: address)
        print(normalizedAddress)
        
        let denormalizedAddress = NEMCore.denormalize(address: normalizedAddress)
        print(denormalizedAddress)
        
        let positiveValidation = NEMCore.valid(address: address)
        print(positiveValidation)
       
    }


}

