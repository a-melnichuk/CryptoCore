//
//  BlockInfo.swift
//  BitcoinCore
//
//  Created by Alex Melnichuk on 8/29/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public struct BlockInfo {
    public let blockIndex: Int32
    public let blockHash: Data
    
    public init(blockIndex: Int32, blockHash: Data) {
        self.blockIndex = blockIndex
        self.blockHash = blockHash
    }
}
