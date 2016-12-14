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

            size.times {
                sampleElements.append(self.sample()!)
            }

            return sampleElements
        }

        return nil
    }

}
