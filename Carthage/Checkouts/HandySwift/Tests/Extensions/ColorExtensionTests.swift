//
//  ColorExtensionTests.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 17.04.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import HandySwift

#if UIKIT

    class ColorExtensionTests: XCTestCase {
        
        func testRgba() {
            
            let color = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4)
            
            XCTAssertEqualWithAccuracy(color.rgba.red, 0.1, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(color.rgba.green, 0.2, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(color.rgba.blue, 0.3, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(color.rgba.alpha, 0.4, accuracy: 0.001)
            
        }
        
        func testHsba() {
            
            let color = UIColor(hue: 0.1, saturation: 0.2, brightness: 0.3, alpha: 0.4)
            
            XCTAssertEqualWithAccuracy(color.hsba.hue, 0.1, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(color.hsba.saturation, 0.2, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(color.hsba.brightness, 0.3, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(color.hsba.alpha, 0.4, accuracy: 0.001)
            
        }
        
        func testChangeAttributeBy() {
            
            let rgbaColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4)
            
            let changedRgbaColor = rgbaColor.change(.Red, by: 0.1).change(.Green, by: 0.1).change(.Blue, by: 0.1).change(.Alpha, by: 0.1)
            
            XCTAssertEqualWithAccuracy(changedRgbaColor.rgba.red, 0.2, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedRgbaColor.rgba.green, 0.3, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedRgbaColor.rgba.blue, 0.4, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedRgbaColor.rgba.alpha, 0.5, accuracy: 0.001)
            
            
            let hsbaColor = UIColor(hue: 0.1, saturation: 0.2, brightness: 0.3, alpha: 0.4)
            
            let changedHsbaColor = hsbaColor.change(.Hue, by: 0.1).change(.Saturation, by: 0.1).change(.Brightness, by: 0.1).change(.Alpha, by: 0.1)
            
            XCTAssertEqualWithAccuracy(changedHsbaColor.hsba.hue, 0.2, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedHsbaColor.hsba.saturation, 0.3, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedHsbaColor.hsba.brightness, 0.4, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedHsbaColor.hsba.alpha, 0.5, accuracy: 0.001)

        }
        
        func testChangeAttributeTo() {
            
            let rgbaColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4)
            
            let changedRgbaColor = rgbaColor.change(.Red, to: 1.0).change(.Green, to: 0.9).change(.Blue, to: 0.8).change(.Alpha, to: 0.7)
            
            XCTAssertEqualWithAccuracy(changedRgbaColor.rgba.red, 1.0, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedRgbaColor.rgba.green, 0.9, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedRgbaColor.rgba.blue, 0.8, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedRgbaColor.rgba.alpha, 0.7, accuracy: 0.001)
            
            
            let hsbaColor = UIColor(hue: 0.1, saturation: 0.2, brightness: 0.3, alpha: 0.4)
            
            let changedHsbaColor = hsbaColor.change(.Hue, to: 1.0).change(.Saturation, to: 0.9).change(.Brightness, to: 0.8).change(.Alpha, to: 0.7)
            
            XCTAssertEqualWithAccuracy(changedHsbaColor.hsba.hue, 1.0, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedHsbaColor.hsba.saturation, 0.9, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedHsbaColor.hsba.brightness, 0.8, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(changedHsbaColor.hsba.alpha, 0.7, accuracy: 0.001)
            
        }
        
    }

#endif