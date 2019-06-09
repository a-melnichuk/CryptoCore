//
//  NEMTransferTransactionMosaic.swift
//  NEMCore
//
//  Created by Alex Melnichuk on 6/7/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore

public protocol NEMTransferTransactionMosaicProtocol {
    var namespace: String { get }
    var mosaic: String { get }
    var quantity: UInt64 { get }
    var supply: UInt64 { get }
    var divisibility: Int { get }
}

public extension NEMTransferTransactionMosaicProtocol {
    var fullName: String {
        return namespace + ":" + mosaic;
    }
    
    func serialized() -> Data {
        let mosaicNameSpaceIdBytes = namespace.nemSerialized
        let mosaicNameBytes = mosaic.nemSerialized
        let mosaicIdStructLength = 4 + mosaicNameSpaceIdBytes.count + 4 + mosaicNameBytes.count
        let mosaicStructLength = 4 + mosaicIdStructLength + 8
        let quantityBytes = Data(loadBytes: quantity.littleEndian)

        var data = Data()
        data.append(mosaicStructLength.nemSerialized)
        data.append(mosaicIdStructLength.nemSerialized)
        data.append(mosaicNameSpaceIdBytes.count.nemSerialized)
        data.append(mosaicNameSpaceIdBytes)
        data.append(mosaicNameBytes.count.nemSerialized)
        data.append(mosaicNameBytes)
        data.append(quantityBytes)
        return data
    }
}

public extension NEMCore.Transfer {
    struct Mosaic: NEMTransferTransactionMosaicProtocol {
        public let namespace: String
        public let mosaic: String
        public let quantity: UInt64
        public let supply: UInt64
        public let divisibility: Int
        
        public init(namespace: String,
                    mosaic: String,
                    quantity: UInt64,
                    supply: UInt64,
                    divisibility: Int) {
            self.namespace = namespace
            self.mosaic = mosaic
            self.quantity = quantity
            self.supply = supply
            self.divisibility = divisibility
        }
    }
}

public extension Array where Element == NEMTransferTransactionMosaicProtocol {
    func nemSerialized() -> Data {
        guard !self.isEmpty else {
            return 0.nemSerialized
        }
        var mosaicBytes = Data()
        self.sorted { $0.fullName < $1.fullName }
            .forEach { mosaicBytes.append($0.serialized()) }
        var data = Data()
        data.append(count.nemSerialized)
        data.append(mosaicBytes)
        return data
    }
}
