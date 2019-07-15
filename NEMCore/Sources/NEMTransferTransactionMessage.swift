//
//  NEMTransactionMessage.swift
//  NEMCore
//
//  Created by Alex Melnichuk on 6/7/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public extension NEMCore.Transfer {
    struct Message {
        /// All available message types.
        public enum Kind: Int {
            case unencrypted = 1
            case encrypted = 2
        }
        
        /// The type of the message.
        public var kind: Kind
        
        /// The payload is the actual (possibly encrypted) message data.
        public var payload: [UInt8]?
        
        /// The message payload (data) as a readable string.
        public var message: String?
        
        // The public key of the account that created the transaction.
        public var signer: String?
        
        public init(kind: Kind, message: String?) {
            self.kind = kind
            self.message = message
            self.payload = message == nil ? nil : [UInt8](message!.utf8)
        }
        
        public mutating func getMessageFromPayload() {
            message = {
                guard let payload = payload else { return "" }
                switch kind {
                case .unencrypted:
                    if payload.first == UInt8(0xfe) {
                        var bytes = payload
                        bytes.removeFirst()
                        return String(bytes: bytes, encoding: .utf8)
                    } else {
                        return String(bytes: payload, encoding: .utf8)
                    }
                case .encrypted:
                    fatalError("\(#function) Encrypted transactions are not supported yet")
                }
            }()
        }
        
        public func serialized() -> Data {
            guard let payload = payload, payload.count > 0 else {
                return 0.nemSerialized
            }
            
            let transactionMessageFieldLengthByteArray = (payload.count + 8).nemSerialized
            let transactionMessageTypeByteArray = kind.rawValue.nemSerialized
            let transactionMessagePayloadLengthByteArray = payload.count.nemSerialized
            let transactionMessagePayloadByteArray = Data(payload)
            
            var data = Data()
            data.append(transactionMessageFieldLengthByteArray)
            data.append(transactionMessageTypeByteArray)
            data.append(transactionMessagePayloadLengthByteArray)
            data.append(transactionMessagePayloadByteArray)
            return data
        }
    }
}

