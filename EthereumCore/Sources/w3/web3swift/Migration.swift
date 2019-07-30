//
//  Merge.swift
//  web3swift-iOS
//
//  Created by Dmitry on 29/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt


/// TIP
/// To quickly fix all renamed functions you can do:
/// 1. (cmd + ') to jump to next issue
/// 2. (ctrl + alt + cmd + f) to fix all issues in current file
/// 3. repeat

// MARK:- web3swift 2.2 changes
public typealias DictionaryReader = AnyReader

// MARK:- web3swift 2.1 changes


@available(*,deprecated: 2.1, renamed: "SolidityDataReader")
public typealias Web3DataResponse = SolidityDataReader

// MARK:- web3swift 2.0 changes

@available (*, deprecated: 2.0, renamed: "Address")
public typealias EthereumAddress = Address




extension Web3Utils {
    @available(*,deprecated: 2.0,message: "Use number.string(units:decimals:decimalSeparator:options:)")
    public static func formatToEthereumUnits(_ bigNumber: BigInt, toUnits: Web3Units = .eth, decimals: Int = 4, decimalSeparator: String = ".") -> String {
        return bigNumber.string(units: toUnits, decimals: decimals, decimalSeparator: decimalSeparator)
    }
    @available(*,deprecated: 2.0,message: "Use number.string(unitDecimals:formattingDecimals:decimalSeparator:options:)")
    public static func formatToPrecision(_ bigNumber: BigInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        var options = BigUInt.StringOptions.default
        if fallbackToScientific {
            options.insert(.fallbackToScientific)
        }
        return bigNumber.string(unitDecimals: numberDecimals, decimals: formattingDecimals, decimalSeparator: decimalSeparator, options: options)
    }
    @available(*,deprecated: 2.0,message: "Use number.string(units:formattingDecimals:decimalSeparator:options:)")
    public static func formatToEthereumUnits(_ bigNumber: BigUInt, toUnits: Web3Units = .eth, decimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        var options = BigUInt.StringOptions.default
        if fallbackToScientific {
            options.insert(.fallbackToScientific)
        }
        return bigNumber.string(units: toUnits, decimals: decimals, decimalSeparator: decimalSeparator, options: options)
    }
    @available(*,deprecated: 2.0,message: "Use number.string(unitDecimals:formattingDecimals:decimalSeparator:options:)")
    public static func formatToPrecision(_ bigNumber: BigUInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        var options = BigUInt.StringOptions.default
        if fallbackToScientific {
            options.insert(.fallbackToScientific)
        }
        return bigNumber.string(unitDecimals: numberDecimals, decimals: formattingDecimals, decimalSeparator: decimalSeparator, options: options)
    }
}
