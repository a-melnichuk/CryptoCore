//
//  AnyPublicKey.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public protocol AnyPublicKey {
    var raw: Data { get }
    func address() -> String?
}
