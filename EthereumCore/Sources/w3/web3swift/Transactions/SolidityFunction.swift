//
//  SolidityFunction.swift
//  web3swift
//
//  Created by Dmitry on 12/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

/// Protocol thats allows to convert types to solidity data
public protocol SolidityDataRepresentable {
    /// - Returns: Solidity compatible data
    var solidityData: Data { get }
    /// - Returns:
    /// `true`: one element equals one byte.
    /// `false`: one element equals 32 bytes.
    /// default: false
    var isSolidityBinaryType: Bool { get }
}
public extension SolidityDataRepresentable {
    var isSolidityBinaryType: Bool { return false }
}

extension BinaryInteger {
    /// - Returns: Solidity compatible data
    public var solidityData: Data { return BigInt(self).abiEncode(bits: 256) }
}
extension Int: SolidityDataRepresentable {}
extension Int8: SolidityDataRepresentable {}
extension Int16: SolidityDataRepresentable {}
extension Int32: SolidityDataRepresentable {}
extension Int64: SolidityDataRepresentable {}
extension BigInt: SolidityDataRepresentable {}
extension UInt: SolidityDataRepresentable {}
extension UInt8: SolidityDataRepresentable {}
extension UInt16: SolidityDataRepresentable {}
extension UInt32: SolidityDataRepresentable {}
extension UInt64: SolidityDataRepresentable {}
extension BigUInt: SolidityDataRepresentable {}
extension Address: SolidityDataRepresentable {
    public var solidityData: Data { return addressData.setLengthLeft(32)! }
}
extension Data: SolidityDataRepresentable {
    public var solidityData: Data { return self }
    public var isSolidityBinaryType: Bool { return true }
}
extension String: SolidityDataRepresentable {
    public var solidityData: Data { return data }
    public var isSolidityBinaryType: Bool { return true }
}
extension Array: SolidityDataRepresentable where Element == SolidityDataRepresentable {
    public var solidityData: Data {
        var data = Data(capacity: 32 * count)
        for element in self {
            data.append(element.solidityData)
        }
        return data
    }
    func data(function: String) -> Data {
        var data = Data(capacity: count * 32 + 4)
        data.append(function.keccak256()[0..<4])
        for element in self {
            data.append(element.solidityData)
        }
        return data
    }
}
