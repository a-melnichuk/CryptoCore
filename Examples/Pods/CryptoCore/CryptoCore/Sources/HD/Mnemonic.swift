//
//  Mnemonic.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/24/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public class Mnemonic {
    public let strength: Strength
    public let language: Language
    private(set) public var array: [String]
    
    public init(_ value: [String], language: Language = .english) {
        self.array = value
        self.strength = Strength(wordCount: array.count)!
        self.language = language
    }
    
    public convenience init(string: String, separatedBy separator: String = " ", language: Language = .english) {
        let array = string.components(separatedBy: separator)
        self.init(array, language: language)
    }
    
    deinit {
        zeroOut()
    }
}

extension Mnemonic: CustomStringConvertible {
    public var description: String {
        return array.joined(separator: " ")
    }
}

extension Mnemonic: ZeroOutable {
    public func zeroOut() {
        array.zeroOut()
    }
}

public extension Mnemonic {
    static func generate(strength: Strength = .default, language: Language = .english) throws -> Mnemonic {
        let byteCount = strength.rawValue / 8
        var bytes = Data(count: byteCount)
        let status: OSStatus = bytes.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, byteCount, $0.baseAddress!)
        }
        guard status == errSecSuccess else {
            throw MnemonicError.randomBytesError
        }
        return try generate(entropy: bytes, language: language)
    }
    
    static func generate(entropy: Data, language: Language = .english) throws -> Mnemonic {
        let list = language.wordList
        var bin = String(entropy.flatMap { byte -> Substring in
            return ("00000000" + String(byte, radix:2)).suffix(8)
        })
        
        guard let hash = Crypto.sha256(entropy) else {
            throw MnemonicError.hashFailed
        }
        let bits = entropy.count * 8
        let cs = bits / 32
        
        let hashbits = String(hash.flatMap { byte -> Substring in
            return ("00000000" + String(byte, radix:2)).suffix(8)
        })
        let checksum = String(hashbits.prefix(cs))
        bin += checksum
        
        var mnemonic = [String]()
        for i in 0..<(bin.count / 11) {
            let wi = Int(bin[bin.index(bin.startIndex, offsetBy: i * 11)..<bin.index(bin.startIndex, offsetBy: (i + 1) * 11)], radix: 2)!
            mnemonic.append(String(list[wi]))
        }
        return Mnemonic(mnemonic, language: language)
    }
    
    static func valid(mnemoic: [String], strength: Strength = .default, language: Language = .english) -> Bool {
        if mnemoic.isEmpty {
            return false
        }
        if mnemoic.count % 3 > 0 {
            // Word list size must be multiple of three words.
            return false
        }
        let list = language.wordList
        
        let concatLenBits = 11 * mnemoic.count
        var concatBits = Array(repeating: false, count: concatLenBits)
        for (wordIndex, word) in mnemoic.enumerated() {
            guard let index = list.binarySearch(word, equal: { $0 == $1 }, less: { $0 < $1 }) else {
                return false
            }
            // Set the next 11 bits to the value of the index.
            for i in 0..<11 {
                concatBits[11 * wordIndex + i] = (index & (1 << (10 - i))) != 0
            }
        }
        
        let checksumLengthBits = concatLenBits / 33;
        let entropyLengthBits = concatLenBits - checksumLengthBits;
        
        if entropyLengthBits != strength.rawValue {
            return false
        }
        
        var entropy = Data(count: entropyLengthBits / 8)
        // Extract original entropy as bytes.
        for i in 0..<entropy.count {
            for j in 0..<8 {
                if concatBits[i * 8 + j] {
                    entropy[i] |= 1 << (7 - j)
                }
            }
        }
        
        guard let hash = Crypto.sha256(entropy) else {
            return false
        }
        var hashBits = Array(repeating: false, count: 8 * hash.count)
        for i in 0..<hash.count {
            for j in 0..<8 {
                hashBits[8 * i + j] = (hash[i] & (1 << (7 - j))) != 0
            }
        }
        
        // Check all the checksum bits.
        for i in 0..<checksumLengthBits {
            if concatBits[entropyLengthBits + i] != hashBits[i] {
                return false
            }
        }
        return true
    }
}

// MARK: - Mnemonic+Language

public extension Mnemonic {
    enum Language {
        case english
        
        var wordList: [Substring] {
            switch self {
            case .english:
                return WordList.english
            }
        }
    }
}

public enum MnemonicError : Error {
    case randomBytesError
    case hashFailed
}


// MARK: - Mnemonic+Strength

public extension Mnemonic {
    enum Strength : Int, CaseIterable {
        case `default` = 128
        case low = 160
        case medium = 192
        case high = 224
        case veryHigh = 256
        
        init?(wordCount: Int) {
            switch wordCount {
            case 12:
                self = .default
            case 15:
                self = .low
            case 18:
                self = .medium
            case 21:
                self = .high
            case 24:
                self = .veryHigh
            default:
                return nil
            }
        }
        
        var wordCount: Int {
            switch self {
            case .default:
                return 12
            case .low:
                return 15
            case .medium:
                return 18
            case .high:
                return 21
            case .veryHigh:
                return 24
            }
        }
    }
}
