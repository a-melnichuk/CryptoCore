//
//  Web3+TransactionIntermediate.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation


/// Parsing errors
public enum Web3ResponseError: Error {
	/// Not found error with response size and index
    case notFound(Int, Int)
	/// Error for unconvertible type
    case wrongType(Any, String, Int)
    /// Printable / user displayable description
	public var localizedDescription: String {
		switch self {
		case let .notFound(index, responseSize):
			if responseSize == 0 {
				return "Trying to get value from response but response is empty"
			} else {
				return "Trying to get value at index \(index). But node response only have \(responseSize) parameters"
			}
		case let .wrongType(result, expected, index):
			return "Cannot convert node response parameter \(index) from \(expected) to \(result)"
		}
	}
}

/// ABIv2 response parser class
public class Web3Response {
	/// Response dictionary
    public let dictionary: [String: Any]
	/// Current position in array
    public var position = 0
	/// Number of arguments in response array
	public var argumentsCount = 0
	/// init with ABIv2 dictionary
    public init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
		var i = 0
		while dictionary["\(i)"] != nil {
			i += 1
		}
		argumentsCount = i
    }
	
	/// - Returns: dictionary[key]
    public subscript(key: String) -> Any? {
        return dictionary[key]
    }

	/// - Returns: dictionary["\(index)"]
    public subscript(index: Int) -> Any? {
        return dictionary["\(index)"]
    }
	
	private var notFound: Web3ResponseError {
		return .notFound(position, argumentsCount)
	}
	private func wrongType(_ expected: String) -> Web3ResponseError {
		return .wrongType(self[position]!, expected, position)
	}
	private var nextIndex: String {
		let p = position
		position += 1
		return String(p)
	}

	/// - Returns: next response argument as BigUInt (like self[n] as? BigUInt; n += 1)
	/// - Throws: Web3ResponseError.notFound if there is no value at self[n].
    /// Web3ResponseError.wrongType if it cannot cast self[n] to BigUInt
    public func uint256() throws -> BigUInt {
        let value = try next()
        if let value = value as? BigUInt {
            return value
        } else if let value = value as? String {
            guard let value = BigUInt(value.withoutHex, radix: 16) else { throw wrongType("BigUInt") }
            return value
        } else {
            throw wrongType("BigUInt")
        }
    }

	/// - Returns: next response argument as Address (like self[n] as? Address; n += 1)
	/// - Throws: Web3ResponseError.notFound if there is no value at self[n].
    /// Web3ResponseError.wrongType if it cannot cast self[n] to Address
    public func address() throws -> Address {
        let value = try next()
        guard let address = value as? Address else { throw wrongType("Address") }
        return address
    }

	/// - Returns: next response argument as String (like self[n] as? String; n += 1)
	/// - Throws: Web3ResponseError.notFound if there is no value at self[n].
	/// Web3ResponseError.wrongType if it cannot cast self[n] to String
    public func string() throws -> String {
        let value = try next()
        guard let string = value as? String else { throw wrongType("String") }
        return string
    }
	
	/// - Returns: next value in response array
	/// - Throws: Web3ResponseError.notFound
    public func next() throws -> Any {
        guard let value = dictionary[nextIndex] else { throw notFound }
        return value
    }
}

/// TransactionIntermediate is an almost-ready transaction or a smart-contract function call. It bears all the required information
/// to call the smart-contract and decode the returned information, or estimate gas required for transaction, or send a transaciton
/// to the blockchain.
public class TransactionIntermediate {
	/// Transaction to send
    var transaction: EthereumTransaction
	/// Contract that contains ABI to parse the response
    var contract: ContractProtocol
	/// JsonRpc method
    var method: String

	/// init with transaction, web3, contract, method and options
    init(transaction: EthereumTransaction, contract: ContractProtocol, method: String, options: Web3Options) {
        self.transaction = transaction
        self.contract = contract
        self.contract.options = options
        self.method = method
    }
}
