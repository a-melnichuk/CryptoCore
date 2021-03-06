//
//  Mnemonic.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/24/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public final class Mnemonic: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
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
    
    public convenience init(stringLiteral value: StringLiteralType) {
        self.init(string: value)
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
            mnemonic.append(language.wordList[wi])
        }
        return Mnemonic(mnemonic, language: language)
    }
    
    static func valid(mnemonic: [String], language: Language = .english) -> Bool {
        if mnemonic.isEmpty {
            return false
        }
        if mnemonic.count % 3 > 0 {
            // Word list size must be multiple of three words.
            return false
        }
        guard let strength = Strength(wordCount: mnemonic.count) else {
            return false
        }
        let list = language.wordList
        
        let concatLenBits = 11 * mnemonic.count
        var concatBits = Array(repeating: false, count: concatLenBits)
        for (wordIndex, word) in mnemonic.enumerated() {
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
        
        public var wordList: [String] {
            switch self {
            case .english:
                return WordList.english
            }
        }
        
        public var validWords: Set<String> {
            return Set(wordList)
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
        
        public init?(wordCount: Int) {
            guard wordCount <= Strength.veryHigh.wordCount else {
                return nil
            }
            let bits = 32 * 11 * wordCount / (32 + 1)
            self.init(rawValue: bits)
        }
        
        public var wordCount: Int {
            let bits = rawValue
            let checksum = bits / 32
            return (bits + checksum) / 11
        }
    }
}
