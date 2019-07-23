//
//  ZeroOuted.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/24/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public final class ZeroOuted<T: ZeroOutable> {
    private(set) public var value: T
    
    public init(_ value: inout T) {
        self.value = value
    }
    
    deinit {
        value.zeroOut()
    }
}

public extension ZeroOuted {
    func withValue<R>(_ action: (inout T) throws -> R) rethrows -> R {
        return try action(&value)
    }
}

public protocol ZeroOutable {
    mutating func zeroOut()
}

extension Data: ZeroOutable {
    mutating public func zeroOut() {
        self.withUnsafeMutableBytes {
            guard let baseAddress = $0.baseAddress,
                $0.count > 0 else {
                    return
            }
            memset(baseAddress, 0, $0.count)
        }
    }
}

extension String: ZeroOutable {
    mutating public func zeroOut() {
        withUnsafeMutableBytes(of: &self) {
            guard let baseAddress = $0.baseAddress,
                $0.count > 0 else {
                    return
            }
            memset(baseAddress, 0, $0.count)
        }
    }
}

extension Array where Element: ZeroOutable {
    mutating public func zeroOut() {
        for i in (0..<count) {
            self[i].zeroOut()
        }
    }
}
