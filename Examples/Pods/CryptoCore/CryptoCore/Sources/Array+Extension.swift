//
//  Array+Extension.swift
//  CryptoCore
//
//  Created by Alex Melnichuk on 6/26/19.
//  Copyright © 2019 Alex Melnichuk. All rights reserved.
//

import Foundation

public extension Array {

    func binarySearch<T>(_ element: T,
                         equal: (Element, T) -> Bool,
                         less: (Element, T) -> Bool) -> Int? {
        var lowerBound = 0
        var upperBound = self.count
        while lowerBound < upperBound {
            let midIndex = lowerBound + (upperBound - lowerBound) / 2
            if equal(self[midIndex], element) {
                return midIndex
            } else if less(self[midIndex], element) {
                lowerBound = midIndex + 1
            } else {
                upperBound = midIndex
            }
        }
        return nil
    }
}

extension Array where Element: Comparable {
    func binarySearch(_ element: Element) -> Int? {
        return binarySearch(element, equal: { $0 == $1 }, less: { $0 < $1 })
    }
}
