//
//  CharacterViewExtension.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 29.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import Foundation

public extension String.CharacterView {

    /// Returns a random character from the `ChracterView`.
    ///
    /// - Returns: A random character from the `CharacterView` or `nil` if empty.
    public func sample() -> Character? {
        if !self.isEmpty {
            let randomIndex = index(startIndex, offsetBy: Int(randomBelow: count))
            return self[randomIndex]
        }

        return nil
    }

    /// Returns a given number of random characters from the `CharacterView`.
    ///
    /// - Parameters:
    ///   - size: The number of random characters wanted.
    /// - Returns: A `CharacterView` with the given number of random characters or `nil` if empty.
    public func sample(size: Int) -> String.CharacterView? {

        if !isEmpty {
            var sampleElements = String.CharacterView()

            size.times {
                sampleElements.append(sample()!)
            }

            return sampleElements
        }

        return String.CharacterView()
    }

}
