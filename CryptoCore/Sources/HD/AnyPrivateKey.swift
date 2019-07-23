//
//  AnyPrivateKey.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public protocol AnyPrivateKey {
    var raw: Data { get }
    
    init?(seed: Seed)
    init?(rawPrivateKey: String)
    
    func anyDerivedPrivateKey(path: BIP32Path) -> AnyPrivateKey?
    func rawPrivateKey() -> String?
    func anyPublicKey() -> AnyPublicKey?
}
