//
//  CoreGraphicsExtensions.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 08.06.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

#if !os(OSX)
    import UIKit
    // MARK: - iOS/tvOS CGSize Extension

    extension CGSize {
        /// Returns a new CGSize object with the width and height converted to true pixels on the main screen.
        public var inPixels: CGSize {
            return inPixels(UIScreen.main)
        }

        /// Returns a new CGSize object with the width and height converted to true pixels on the given screen.
        ///
        /// - Parameters:
        ///   - screen: The target screen to convert to pixels for.
        public func inPixels(_ screen: UIScreen) -> CGSize {
            return CGSize(width: width * screen.scale, height: height * screen.scale)
        }
    }


    // MARK: - iOS/tvOS CGPoint Extension

    extension CGPoint {
        /// Returns a new CGPoint object with the x and y converted to true pixels on the main screen.
        public var inPixels: CGPoint {
            return inPixels(UIScreen.main)
        }

        /// Returns a new CGPoint object with the x and y converted to true pixels on the given screen.
        ///
        /// - Parameters:
        ///   - screen: The target screen to convert to pixels for.
        public func inPixels(_ screen: UIScreen) -> CGPoint {
            return CGPoint(x: x * screen.scale, y: y * screen.scale)
        }
    }


    // MARK: - iOS/tvOS CGRect Extension

    extension CGRect {
        /// Returns a new CGRect object with the origin and size converted to true pixels on the main screen.
        public var inPixels: CGRect {
            return inPixels(UIScreen.main)
        }

        /// Returns a new CGRect object with the origin and size converted to true pixels on the given screen.
        ///
        /// - Parameters:
        ///   - screen: The target screen to convert to pixels for.
        public func inPixels(_ screen: UIScreen) -> CGRect {
            return CGRect(origin: origin.inPixels(screen), size: size.inPixels(screen))
        }
    }
#endif


// MARK: - Shared CGRect Extension

extension CGRect {
    /// Creates a new CGRect object from origin zero with given size.
    ///
    /// - Parameters:
    ///   - size: The size of the new rect.
    public init(size: CGSize) {
        self.init(origin: CGPoint.zero, size: size)
    }

    /// Creates a new CGRect object from origin zero with given size.
    ///
    /// - Parameters:
    ///   - width: The width of the new rect.
    ///   - height: The height of the new rect.
    public init(width: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint.zero, size: CGSize(width: width, height: height))
    }
}
