//
//  CryptoCoreUtil.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 5/2/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import paytomat_crypto_core

public extension Crypto {
    static func randomBytes(_ count: Int) -> Data? {
        var randomBytes = Data(count: count)
        let result: ptc_result = randomBytes.withUnsafeMutableBytes { buf in
            if let ptr = buf.bindMemory(to: UInt8.self).baseAddress {
                return ptc_random_bytes(ptr, buf.count)
            }
            return PTC_ERROR_GENERAL
        }
        return result == PTC_SUCCESS ? randomBytes : nil
    }
}
