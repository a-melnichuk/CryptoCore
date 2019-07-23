//
//  String+Extension.swift
//  EthereumCore
//
//  Created by Alex Melnichuk on 7/23/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation
import CryptoCore
import web3swift

public extension String {
    
    var withEthereumPrefix: String {
        if self.hasPrefix(EthereumCore.prefix) {
            return self
        }
        return EthereumCore.prefix + self
    }
    
    var withoutEthereumPrefix: String {
        if starts(with: EthereumCore.prefix) {
            let start = index(startIndex, offsetBy: EthereumCore.prefix.count)
            return String(suffix(from: start))
        }
        return self
    }
    
    var isValidEthereumAddress: Bool {
        
        if !NSPredicate(format: "SELF MATCHES %@", "^(0x)?[0-9a-f]{40}$").evaluate(with: lowercased()) {
            return false
        }
        
        if NSPredicate(format: "SELF MATCHES %@", "^(0x)?[0-9a-f]{40}$").evaluate(with: self) {
            return true
        }
        
        if NSPredicate(format: "SELF MATCHES %@", "^(0x)?[0-9A-F]{40}$").evaluate(with: self) {
            return true
        }
        
        // Validate checksum
        let address = self.withoutEthereumPrefix.lowercased()
        let addressData = Data(address.utf8)
        guard let addressHashData = Crypto.keccak256(addressData) else {
            return false
        }
        let addressHash = Hex.encode(addressHashData)
        guard address.count >= 40, addressHash.count >= 40 else {
            return false
        }
        
        for i in 0..<40 {
            let hashIndex = addressHash.index(addressHash.startIndex, offsetBy: i)
            let addressIndex = address.index(address.startIndex, offsetBy: i)
            
            let hashString = String(addressHash[hashIndex])
            let addressString = String(address[addressIndex])
            
            let hashInt = Int(strtoul(hashString, nil, 16))
            
            // the nth letter should be uppercase if the nth digit of casemap is 1
            if ((hashInt > 7 && addressString.uppercased() != addressString)
                || (hashInt <= 7 && addressString.lowercased() != addressString)) {
                return false
            }
        }
        return true
    }
    
    
    
}
