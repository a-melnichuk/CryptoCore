//
//  ContractProtocol.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

/// Contract protocol
/// At this moment uses only in ContractV2
protocol ContractProtocol {
    
    /// Contract address
    var address: Address? { get set }
    
    /// Default sending options
    var options: Web3Options { get set }
    
    /// Contract methods
    var allMethods: [String] { get }
    
    /// Contract events
    var allEvents: [String] { get }

    /// Converts method to EthereumTransaction that you can call or send later
    /// - Parameter method: Contract function name
    /// - Parameter parameters: Function arguments
    /// - Parameter extraData: Extra data for transaction
    /// - Parameter options: Transaction options
    /// - Returns: Prepared transaction
    func method(_ method: String, parameters: [Any], extraData: Data, options: Web3Options?) throws -> EthereumTransaction
    
    /// init for deployed contract
    init(_ abiString: String, at address: Address?) throws
    
    /// Decodes smart contract response to dictionary
    /// - Parameter method: Smart contract function name
    /// - Parameter data: Smart contract response data
    func decodeReturnData(_ method: String, data: Data) -> [String: Any]?
    
    /// Decodes input arguments to dictionary
    /// - Parameter method: Smart contract function name
    /// - Parameter data: Smart contract input data
    func decodeInputData(_ method: String, data: Data) -> [String: Any]?
    
    /// Searches for smart contract method and decodes input arguments to dictionary
    /// - Parameter data: Smart contract input data
    func decodeInputData(_ data: Data) -> [String: Any]?
    
}
