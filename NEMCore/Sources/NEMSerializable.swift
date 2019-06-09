//
//  NEMSerializable.swift
//  NEMCore
//
//  Created by Alex Melnichuk on 6/7/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

protocol NEMSerializable {
    var nemSerialized: Data { get }
}

extension Int: NEMSerializable {
    var nemSerialized: Data {
        let uint32 = UInt32(truncatingIfNeeded: self).littleEndian
        return Data(loadBytes: uint32)
    }
}

extension String: NEMSerializable {
    var nemSerialized: Data {
        return Data(self.utf8)
    }
}
