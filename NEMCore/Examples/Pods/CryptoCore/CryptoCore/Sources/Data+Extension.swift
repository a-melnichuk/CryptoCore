//
//  Data+Extension.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/4/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public extension Data {
    init<T>(loadBytes value: T) {
        var value: T = value
        self = withUnsafePointer(to: &value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) {
                Data(buffer: UnsafeBufferPointer(start: $0, count: MemoryLayout<T>.size))
            }
        }
    }
    
    func loadType<T>(_: T.Type) -> T {
        return self.withUnsafeBytes {
            $0.baseAddress!.load(as: T.self)
        }
    }
}
