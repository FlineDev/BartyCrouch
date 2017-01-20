//
//  CoreGraphicsExtensionsTests.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 08.06.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import HandySwift

// Note: The tests in here work best if run on a Retina device (e.g. iPhone 6s Plus Simulator).
class CoreGraphicsExtensionsTests: XCTestCase {
    let size: CGFloat = 22

#if !os(OSX)
    func testCGSizeInPixels() {
        let testSize = CGSize(width: size, height: size)

        #if !os(OSX)
            let expectedPixelSize = size * UIScreen.main.scale
        #else
            let expectedPixelSize = size * (NSScreen.main()?.backingScaleFactor)!
        #endif

        let testSizeInPixels = testSize.inPixels

        XCTAssertEqualWithAccuracy(testSizeInPixels.width, expectedPixelSize, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testSizeInPixels.height, expectedPixelSize, accuracy: 0.001)
    }

    func testCGSizeInPixelsScreen() {
        let testSize = CGSize(width: size, height: size)

        #if !os(OSX)
            let testScreen = UIScreen()
            let expectedPixelSize = size * testScreen.scale
        #else
            let testScreen = NSScreen()
            let expectedPixelSize = size * testScreen.backingScaleFactor
        #endif

        let testSizeInPixels = testSize.inPixels(testScreen)

        XCTAssertEqualWithAccuracy(testSizeInPixels.width, expectedPixelSize, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testSizeInPixels.height, expectedPixelSize, accuracy: 0.001)
    }

    func testCGPointInPixels() {
        let testPoint = CGPoint(x: size, y: size)

        #if !os(OSX)
            let expectedPixelPointSizes = size * UIScreen.main.scale
        #else
            let expectedPixelPointSizes = size * NSScreen.main()!.backingScaleFactor
        #endif

        let testPointInPixels = testPoint.inPixels

        XCTAssertEqualWithAccuracy(testPointInPixels.x, expectedPixelPointSizes, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testPointInPixels.y, expectedPixelPointSizes, accuracy: 0.001)
    }

    func testCGPointInPixelsScreen() {
        let testPoint = CGPoint(x: size, y: size)

		#if !os(OSX)
            let testScreen = UIScreen()
            let expectedPixelPointSizes = size * testScreen.scale
        #else
            let testScreen = NSScreen()
            let expectedPixelPointSizes = size * testScreen.backingScaleFactor
        #endif

        let testPointInPixels = testPoint.inPixels(testScreen)

        XCTAssertEqualWithAccuracy(testPointInPixels.x, expectedPixelPointSizes, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testPointInPixels.y, expectedPixelPointSizes, accuracy: 0.001)
    }

    func testCGRectInPixels() {
        let testRect = CGRect(x: size, y: size, width: size, height: size)

        #if !os(OSX)
            let expectedPixelRectSizes = size * UIScreen.main.scale
            let testRectInPixels = testRect.inPixels
        #else
            let expectedPixelRectSizes = size * NSScreen.main()!.backingScaleFactor
            let testRectInPixels = testRect.inPixels!
        #endif

        XCTAssertEqualWithAccuracy(testRectInPixels.origin.x, expectedPixelRectSizes, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRectInPixels.origin.y, expectedPixelRectSizes, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRectInPixels.size.width, expectedPixelRectSizes, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRectInPixels.size.height, expectedPixelRectSizes, accuracy: 0.001)
    }

    func testCGRectInPixelsScreen() {
        let testRect = CGRect(x: size, y: size, width: size, height: size)

		#if !os(OSX)
            let testScreen = UIScreen()
            let expectedPixelRectSizes = size * testScreen.scale
        #else
            let testScreen = NSScreen()
            let expectedPixelRectSizes = size * testScreen.backingScaleFactor
        #endif

        let testRectInPixels = testRect.inPixels(testScreen)

        XCTAssertEqualWithAccuracy(testRectInPixels.origin.x, expectedPixelRectSizes, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRectInPixels.origin.y, expectedPixelRectSizes, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRectInPixels.size.width, expectedPixelRectSizes, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRectInPixels.size.height, expectedPixelRectSizes, accuracy: 0.001)
    }
#endif

    func testCGRectInitSize() {
        let testSize = CGSize(width: size, height: size)
        let testRect = CGRect(size: testSize)

        XCTAssertEqualWithAccuracy(testRect.origin.x, 0.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRect.origin.y, 0.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRect.size.width, testSize.width, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRect.size.height, testSize.height, accuracy: 0.001)
    }

    func testCGRectInitWidthHeight() {
        let testRect = CGRect(width: size, height: size)

        XCTAssertEqualWithAccuracy(testRect.origin.x, 0.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRect.origin.y, 0.0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRect.size.width, size, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(testRect.size.height, size, accuracy: 0.001)
    }
}
