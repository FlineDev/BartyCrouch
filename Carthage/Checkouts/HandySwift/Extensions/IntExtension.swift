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

    /// Runs the code passed as a closure the specified number of times.
    ///
    /// - Parameters:
    ///   - closure: The code to be run multiple times.
    public func times(_ closure: () -> Void) {
        guard self > 0 else { return }
        for _ in 0..<self { closure() }
    }

    /// Runs the code passed as a closure the specified number of times
    /// and creates an array from the return values.
    ///
    /// - Parameters:
    ///   - closure: The code to deliver a return value multiple times.
    public func timesMake<ReturnType>(_ closure: () -> ReturnType) -> [ReturnType] {
        guard self > 0 else { return [] }
        return (0..<self).map { _ in return closure() }
    }
}
