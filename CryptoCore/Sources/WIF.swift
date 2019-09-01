//
//  WIF.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 8/29/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public struct WIF {
    
    public static func encode(_ data: Data, version: [UInt8], compressed: Bool = true) -> String? {
        var data = data
        if compressed {
            data.append(0x01)
        }
        return Base58Check.encode(data, version: version)
    }
    
    public static func decode(_ string: String, version: [UInt8], compressed: Bool = true) -> Data? {
        guard var decoded = Base58Check.decode(string, version: version) else {
            return nil
        }
        if compressed {
            decoded = decoded.dropLast()
        }
        return decoded
    }
    
    private init() {}
}
