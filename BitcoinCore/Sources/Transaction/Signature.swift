//
//  Signature.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 8/29/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public struct Signature {
    public static let SIGHASH_ALL: UInt8 = 0x01
    public static let SIGHASH_NONE: UInt8 = 0x02
    public static let SIGHASH_SINGLE: UInt8 = 0x03
    public static let SIGHASH_ANYONECANPAY: UInt8 = 0x80
}

