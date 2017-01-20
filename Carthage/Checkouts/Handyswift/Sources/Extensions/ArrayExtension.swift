//
//  ArrayExtension.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import Foundation

public extension Array {
    /// Returns a random element from the `Array`.
    ///
    /// - Returns: A random element from the array or `nil` if empty.
    public func sample() -> Element? {
        if !self.isEmpty {
            let randomIndex = startIndex.advanced(by: Int(randomBelow: self.count))
            return self[randomIndex]
        }
        return nil
    }

    /// Returns a given number of random elements from the `Array`.
    ///
    /// - Parameters:
    ///   - size: The number of random elements wanted.
    /// - Returns: An array with the given number of random elements or `nil` if empty.
    public func sample(size: Int) -> [Element]? {
        if !isEmpty {
            var sampleElements: [Element] = []
            size.times { sampleElements.append(self.sample()!) }
            return sampleElements
        }
        return nil
    }

    /// Combines each element with each element of a given array.
    ///
    /// Also known as: Cartesian product.
    ///
    /// - Parameters:
    ///   - other: Other array to combine the elements with.
    /// - Returns: An array of tuples with the elements of both arrays combined.
    public func combinations<T>(with other: [T]) -> [(Element, T)] {
        var combinations = [(Element, T)]()
        self.forEach { elem in
            other.forEach { otherElem in
                combinations.append((elem, otherElem))
            }
        }
        return combinations
    }
}
