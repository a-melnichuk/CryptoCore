//
//  NEMTransferTransaction+Fee.swift
//  NEMCore
//
//  Created by Alex Melnichuk on 6/7/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public extension NEMCore.Transfer {
    private static let feePer10000MicroXEM: UInt64 = 50_000
    private static let maxFeeMicroXEM: UInt64 = 1_250_000
    
    static func fee(for amount: UInt64,
                    message: String?,
                    messageEncrypted: Bool = false,
                    mosaics: [NEMTransferTransactionMosaicProtocol] = []) -> UInt64 {
        // Amount must not be computed for transaction with mosaics
        let messageFee = self.computeFee(for: message, encrypted: messageEncrypted)
        if mosaics.isEmpty {
            let amountFee = self.computeFee(for: amount)
            return amountFee + messageFee
        } else {
            let mosaicsFee = self.computeFee(for: mosaics)
            return mosaicsFee + messageFee
        }
    }
    
    static func fee(for amount: UInt64,
                    message: String?,
                    messageEncrypted: Bool = false,
                    mosaic: NEMTransferTransactionMosaicProtocol?) -> UInt64 {
        return fee(for: amount,
                   message: message,
                   messageEncrypted: messageEncrypted,
                   mosaics: mosaic == nil ? [] : [mosaic!])
    }
    
    private static func computeFee(for amount: UInt64) -> UInt64 {
        let count100000 = amount / 10_000
        let fee = feePer10000MicroXEM * count100000
        return max(feePer10000MicroXEM, min(maxFeeMicroXEM, fee))
    }
    
    private static func computeFee(for message: String?, encrypted: Bool) -> UInt64 {
        guard let message = message, !message.isEmpty else {
            return 0
        }
        let messageData = Data(message.utf8)
        let messageSize = messageData.count + (encrypted ? 64 : 0)
        let messagePrice = UInt64(Double(messageSize) / 32) + 1
        return feePer10000MicroXEM * messagePrice
    }
    
    private static func computeFee(for mosaics: [NEMTransferTransactionMosaicProtocol]) -> UInt64 {
        var fee: UInt64 = 0
        let minFee = feePer10000MicroXEM
        let maxMosaicQuantity: Int64 = 9_000_000_000_000_000
        let xemEquivalentPrice: Int64 = 8_999_999_999
        for mosaic in mosaics {
            if mosaic.divisibility == 0 && mosaic.supply < 10_000 {
                fee += minFee
                continue
            }
            let totalMosaicQuantity = Double(mosaic.supply) * pow(10.0, Double(mosaic.divisibility))
            let supplyRelatedAdjustment = Int64(floor(0.8 * log(Double(maxMosaicQuantity) / totalMosaicQuantity)))
            
            let xemEquivalent: Decimal = Decimal(xemEquivalentPrice) * Decimal(mosaic.quantity) / Decimal(totalMosaicQuantity)
            let microXemEquivalent = NSDecimalNumber(decimal: xemEquivalent * 1e6).int64Value
            var microXemEquivalentFee = (microXemEquivalent / 10_000_000_000) * Int64(minFee)
            microXemEquivalentFee = max(Int64(minFee), min(Int64(maxFeeMicroXEM), microXemEquivalentFee))
            
            let calculatedFee = microXemEquivalentFee - Int64(minFee) * supplyRelatedAdjustment
            fee += UInt64(max(Int64(minFee), calculatedFee))
        }
        return fee
    }
}
