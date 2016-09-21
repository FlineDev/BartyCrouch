// StringExtensionTests.swift
//
// Copyright (c) 2014 Ayaka Nonaka
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
import Polyglot

class StringExtensionTests: XCTestCase {

    func testURLEncoded() {
        AssertEqualOptional(" ".urlEncoded, "%20")
        AssertEqualOptional("polyglot://".urlEncoded, "polyglot://")
        AssertEqualOptional("Spreek je Nederlands?".urlEncoded, "Spreek%20je%20Nederlands%3F")
        AssertEqualOptional("1+1=2".urlEncoded, "1%2B1%3D2")
        AssertEqualOptional("ampers&".urlEncoded, "ampers%26")
    }
    
    func testLanguage() {
        AssertEqualOptional("أنا بحب الشوكولا".language, Language.Arabic)
        AssertEqualOptional("J' aime le chocolat".language, Language.French)
        XCTAssertNil("".language?.rawValue, "Empty strings should return nil.")
    }

    func AssertEqualOptional<T : Equatable>(@autoclosure optional:  () -> T?, @autoclosure _ expected:  () -> T, file: String = #file, line: UInt = #line) {
        if let nonOptional = optional() {
            if nonOptional != expected() {
                self.recordFailureWithDescription("Optional (\(nonOptional)) is not equal to (\(expected()))", inFile: file, atLine: line, expected: true)
            }
        }
        else {
            self.recordFailureWithDescription("Optional value is empty", inFile: file, atLine: line, expected: true)
        }
    }

}
