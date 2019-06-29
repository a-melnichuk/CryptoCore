//
//  Seed.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/26/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public final class Seed {
    private(set) public var raw: Data
    
    public init(_ raw: Data) {
        self.raw = raw
    }
    
    public convenience init?(mnemonic: Mnemonic, passphrase: String = "") {
        let mnemonicString = mnemonic.array.joined(separator: " ")
        var mnemonic = Data(mnemonicString.decomposedStringWithCompatibilityMapping.utf8)
        defer { mnemonic.zeroOut() }
        let salt = ("mnemonic" + passphrase).decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        guard var rawSeed = Crypto.Key.derive(password: mnemonic, salt: salt, iterations: 2048, keyLength: 64) else {
            return nil
        }
        defer { rawSeed.zeroOut() }
        self.init(rawSeed)
    }
   
    deinit {
        zeroOut()
    }
}

extension Seed: ZeroOutable {
    public func zeroOut() {
        raw.zeroOut()
    }
}
