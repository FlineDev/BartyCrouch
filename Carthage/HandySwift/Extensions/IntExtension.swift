//
//  IntegerTypeExtension.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 18.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import Foundation

extension Int {
    /// Initializes a new `Int ` instance with a random value below a given `Int`.
    ///
    /// - Parameters:
    ///   - randomBelow: The upper bound value to create a random value with.
    public init?(randomBelow upperLimit: Int) {
        guard upperLimit > 0 else { return nil }
        self.init(arc4random_uniform(UInt32(upperLimit)))
    }
}
