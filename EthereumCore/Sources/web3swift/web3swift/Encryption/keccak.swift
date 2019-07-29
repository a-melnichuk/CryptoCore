//
//  File.swift
//  web3swift
//
//  Created by Dmitry on 05/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import CryptoCore

extension Data {
    var pointer: UnsafePointer<UInt8>! { return withUnsafeBytes { $0 } }
    mutating func mutablePointer() -> UnsafeMutablePointer<UInt8>! {
        return withUnsafeMutableBytes { $0 }
    }
    
    /// - Returns: kaccak256 hash of data
    public func keccak256() -> Data {
        var data = self
        return CryptoCore.Crypto.keccak256(data)!
    }
}
