//
//  Web3+Structures.swift
//
//  Created by Alexander Vlasov on 26.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

fileprivate func decodeHexToData<T>(_ container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key, allowOptional: Bool = false) throws -> Data? {
    if allowOptional {
        let string = try? container.decode(String.self, forKey: key)
        if string != nil {
            guard let data = Data.fromHex(string!) else { throw Web3Error.dataError }
            return data
        }
        return nil
    } else {
        let string = try container.decode(String.self, forKey: key)
        guard let data = Data.fromHex(string) else { throw Web3Error.dataError }
        return data
    }
}

fileprivate func decodeHexToBigUInt<T>(_ container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key, allowOptional: Bool = false) throws -> BigUInt? {
    if allowOptional {
        let string = try? container.decode(String.self, forKey: key)
        if string != nil {
            guard let number = BigUInt(string!.withoutHex, radix: 16) else { throw Web3Error.dataError }
            return number
        }
        return nil
    } else {
        let string = try container.decode(String.self, forKey: key)
        guard let number = BigUInt(string.withoutHex, radix: 16) else { throw Web3Error.dataError }
        return number
    }
}

extension Web3Options: Decodable {
    enum CodingKeys: String, CodingKey {
        case from
        case to
        case gasPrice
        case gas
        case value
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let gasLimit = try decodeHexToBigUInt(container, key: .gas)
        self.gasLimit = gasLimit

        let gasPrice = try decodeHexToBigUInt(container, key: .gasPrice)
        self.gasPrice = gasPrice

        let toString = try container.decode(String?.self, forKey: .to)
        var to: Address?
        if toString == nil || toString == "0x" || toString == "0x0" {
            to = Address.contractDeployment
        } else {
            guard let addressString = toString else { throw Web3Error.dataError }
            let ethAddr = Address(addressString)
            guard ethAddr.isValid else { throw Web3Error.dataError }
            to = ethAddr
        }
        self.to = to
        let from = try container.decodeIfPresent(Address.self, forKey: .to)
//        var from: Address?
//        if fromString != nil {
//            guard let ethAddr = Address(toString) else { throw Web3Error.dataError }
//            from = ethAddr
//        }
        self.from = from

        let value = try decodeHexToBigUInt(container, key: .value)
        self.value = value
    }
}

extension EthereumTransaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case to
        case data
        case input
        case nonce
        case v
        case r
        case s
        case value
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let options = try Web3Options(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var data = try decodeHexToData(container, key: .data, allowOptional: true)
        if data != nil {
            self.data = data!
        } else {
            data = try decodeHexToData(container, key: .input, allowOptional: true)
            if data != nil {
                self.data = data!
            } else {
                throw Web3Error.dataError
            }
        }

        guard let nonce = try decodeHexToBigUInt(container, key: .nonce) else { throw Web3Error.dataError }
        self.nonce = nonce

        guard let v = try decodeHexToBigUInt(container, key: .v) else { throw Web3Error.dataError }
        self.v = v

        guard let r = try decodeHexToBigUInt(container, key: .r) else { throw Web3Error.dataError }
        self.r = r

        guard let s = try decodeHexToBigUInt(container, key: .s) else { throw Web3Error.dataError }
        self.s = s

        if options.value == nil || options.to == nil || options.gasLimit == nil || options.gasPrice == nil {
            throw Web3Error.dataError
        }
        chainID = nil
        value = options.value!
        to = options.to!
        gasPrice = options.gasPrice!
        gasLimit = options.gasLimit!

        if let inferedChainID = inferedChainID, v >= 37 {
            chainID = inferedChainID
        }
    }
}

/**
# TransactionDetails
Used as result of Web3.default.eth.getTransactionDetails
*/
public struct TransactionDetails {
	/// Block hash in a blockchain
    public var blockHash: Data?
	/// Block number in a blockchain
    public var blockNumber: BigUInt?
	/// Transaction index in a block
    public var transactionIndex: BigUInt?
	/// Transaction info
    var transaction: EthereumTransaction

    enum CodingKeys: String, CodingKey {
        case blockHash
        case blockNumber
        case transactionIndex
    }
}

extension Address: Decodable, Encodable {
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        self.init(stringValue)
    }
    
    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        let value = address.lowercased()
        var signleValuedCont = encoder.singleValueContainer()
        try signleValuedCont.encode(value)
    }
}
