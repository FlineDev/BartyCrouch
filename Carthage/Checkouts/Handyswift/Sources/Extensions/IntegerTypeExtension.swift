//
//  IntegerTypeExtension.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 29.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import Foundation

extension Int {

    /// Runs the code passed as a closure the specified number of times.
    ///
    /// - Parameters:
    ///   - closure: The code to be run multiple times.
    public func times(_ closure: () -> Void) {
        guard self > 0 else { return }

        for _ in 1...self {
            closure()
        }
    }

}
