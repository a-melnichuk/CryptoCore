//
//  Web3.swift
//  web3swift
//
//  Created by Alexander Vlasov on 11.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

/// Web3 errors
public enum Web3Error: Error {
    /// Transaction serialization failed
    case transactionSerializationError
    /// Cannot connect to local node
    case connectionError
    /// Cannot decode data
    case dataError
    /// Input error: \(string)
    case inputError(String)
    /// Node error: \(string)
    case nodeError(String)
    /// Processing error: \(string)
    case processingError(String)
    /// Printable / user displayable description
    public var localizedDescription: String {
        switch self {
        case .transactionSerializationError:
            return "Transaction serialization failed"
        case .connectionError:
            return "Cannot connect to local node"
        case .dataError:
            return "Cannot decode data"
        case let .inputError(string):
            return "Input error: \(string)"
        case let .nodeError(string):
            return "Node error: \(string)"
        case let .processingError(string):
            return "Processing error: \(string)"
        }
    }
}

