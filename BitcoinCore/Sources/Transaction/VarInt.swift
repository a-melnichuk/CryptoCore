//
//  VarInt.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 8/29/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

/// Integer can be encoded depending on the represented value to save space.
/// Variable length integers always precede an array/vector of a type of data that may vary in length.
/// Longer numbers are encoded in little endian.

public struct VarInt : ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt64
    public let underlyingValue: UInt64
    public let length: UInt8
    public let data: Data
    
    public init(_ value: UInt64) {
        underlyingValue = value
        var data = Data()
        switch value {
        case 0...252:
            length = 1
            data.append(UInt8(value).littleEndian)
        case 253...0xffff:
            length = 2
            data.append(UInt8(0xfd).littleEndian)
            data.append(Data(loadBytes: UInt16(value).littleEndian))
        case 0x10000...0xffffffff:
            length = 4
            data.append(UInt8(0xfe).littleEndian)
            data.append(Data(loadBytes: UInt32(value).littleEndian))
        case 0x100000000...0xffffffffffffffff:
            fallthrough
        default:
            length = 8
            data.append(UInt8(0xff).littleEndian)
            data.append(Data(loadBytes: UInt64(value).littleEndian))
        }
        self.data = data
    }
    
    public init(integerLiteral value: UInt64) {
        self.init(value)
    }
    
    public init(_ value: Int) {
        self.init(UInt64(value))
    }
    
    public func serialized() -> Data {
        return data
    }
}

extension VarInt : CustomStringConvertible {
    public var description: String {
        return "\(underlyingValue)"
    }
}
