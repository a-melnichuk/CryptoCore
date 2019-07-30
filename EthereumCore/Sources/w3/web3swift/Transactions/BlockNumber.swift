//
//  Block.swift
//  web3swift
//
//  Created by Dmitry on 14/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

/// Block number type. earliest, latest and pending are tags.
public enum BlockNumberType: String {
    case exact, earliest, latest, pending
}

/// Work in progress. Will be released in 2.2 - 2.3
public struct BlockNumber {
    /// Block number tag
    public var type: BlockNumberType
    /// Block number offset. Allows you to use .latest - 5
    public var offset: Int = 0
    /// Init with type and offset
    public init(type: BlockNumberType, offset: Int = 0) {
        self.type = type
        self.offset = offset
    }
    /// Init with block number.
    /// Accepts "latest" "pending" "earliest" "1234" "0x90af".
    public init(_ string: String) {
        switch string {
        case "latest":
            type = .latest
        case "pending":
            type = .pending
        case "earliest":
            type = .earliest
        default:
            type = .exact
            offset = try! AnyReader(string).int()
        }
    }
    
    
    /// Returns "latest" block number
    public static var latest: BlockNumber {
        return BlockNumber(type: .latest)
    }
    /// Returns "earliest" block number
    public static var earliest: BlockNumber {
        return BlockNumber(type: .earliest)
    }
    /// Returns "pending" block number
    public static var pending: BlockNumber {
        return BlockNumber(type: .pending)
    }
    
    /// Math method for block numbers
    public static func - (l: BlockNumber, r: Int) -> BlockNumber {
        var v = l
        v.offset -= r
        return v
    }
    
    /// Math method for block numbers
    public static func + (l: BlockNumber, r: Int) -> BlockNumber {
        var v = l
        v.offset -= r
        return v
    }
}

extension BlockNumber: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        type = .exact
        offset = value
    }
}

extension BlockNumber: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
