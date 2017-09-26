/*
 * StringExtensionTests.swift
 * Copyright (c) 2014 Ben Gollmer.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import XCTest
@testable import CommandLineKit

class StringExtensionTests: XCTestCase {
  static var allTests : [(String, (StringExtensionTests) -> () throws -> Void)] {
    return [
      ("testToDouble", testToDouble),
      ("testSplit", testSplit),
      ("testPadded", testPadded),
      ("testWrapped", testWrapped),
    ]
  }

  override func setUp() {
    /* set locale to "C" to start with '.' as the decimal separator */
    setlocale(LC_ALL, "C")
  }

  func testToDouble() {
    /* Regular ol' double */
    let a = "3.14159".toDouble()
    XCTAssertEqual(a, 3.14159, "Failed to parse pi as double")

    let b = "-98.23".toDouble()
    XCTAssertEqual(b, -98.23, "Failed to parse negative double")

    /* Ints should be parsable as doubles */
    let c = "5".toDouble()
    XCTAssertEqual(c, 5, "Failed to parse int as double")

    let d = "-2099".toDouble()
    XCTAssertEqual(d, -2099, "Failed to parse negative int as double")


    /* Zero handling */
    let e = "0.0".toDouble()
    XCTAssertEqual(e, 0, "Failed to parse zero double")

    let f = "0".toDouble()
    XCTAssertEqual(f, 0, "Failed to parse zero int as double")

    let g = "0.0000000000000000".toDouble()
    XCTAssertEqual(g, 0, "Failed to parse very long zero double")

    let h = "-0.0".toDouble()
    XCTAssertEqual(h, 0, "Failed to parse negative zero double")

    let i = "-0".toDouble()
    XCTAssertEqual(i, 0, "Failed to parse negative zero int as double")

    let j = "-0.000000000000000".toDouble()
    XCTAssertEqual(j, 0, "Failed to parse very long negative zero double")


    /* Various extraneous chars */
    let k = "+42.3".toDouble()      // 4 Jan 2017: leading + is valid language syntax
    XCTAssertEqual(k, 42.3, "Failed to parse double with leading +")

    let l = " 827.2".toDouble()
    XCTAssertNil(l, "Parsed double with extraneous space")

    let m = "283_3".toDouble()
    XCTAssertNil(m, "Parsed double with extraneous _")

    let n = "💩".toDouble()
    XCTAssertNil(n, "Parsed poo")

    /* Locale handling */
    setlocale(LC_NUMERIC, "sv_SE.UTF-8")

    let o = "888,8".toDouble()
    XCTAssert(o == 888.8, "Failed to parse double in alternate locale")

    let p = "888.8".toDouble()
    XCTAssertNil(p, "Parsed double in alternate locale with wrong decimal point")

    /* Set locale back so as not to perturb any other tests */
    setlocale(LC_NUMERIC, "")
  }

  func testSplit() {
    let a = "1,2,3".split(by: ",")
    XCTAssertEqual(a.count, 3, "Failed to split into correct number of components")

    let b = "123".split(by: ",")
    XCTAssertEqual(b.count, 1, "Failed to split when separator not found")

    let c = "".split(by: ",")
    XCTAssertEqual(c.count, 0, "Splitting empty string should return empty array")

    let e = "a-b-c-d".split(by: "-", maxSplits: 2)
    XCTAssertEqual(e.count, 3, "Failed to limit splits")
    XCTAssertEqual(e[0], "a", "Invalid value for split 1")
    XCTAssertEqual(e[1], "b", "Invalid value for split 2")
    XCTAssertEqual(e[2], "c-d", "Invalid value for last split")
  }

  func testPadded() {
    let a = "this is a test"

    XCTAssertEqual(a.padded(toWidth: 80).characters.count,
                   80, "Failed to pad to correct width")
    XCTAssertEqual(a.padded(toWidth: 5).characters.count,
                   a.characters.count, "Bad padding when pad width is less than string width")
    XCTAssertEqual(a.padded(toWidth: -2).characters.count,
                   a.characters.count, "Bad padding with negative pad width")

    let b = a.padded(toWidth: 80)
    let lastBCharIndex = b.index(before: b.endIndex)
    XCTAssertEqual(b[lastBCharIndex], " " as Character, "Failed to pad with default character")

    let c = a.padded(toWidth: 80, with: "+")
    let lastCCharIndex = c.index(before: b.endIndex)
    XCTAssertEqual(c[lastCCharIndex], "+" as Character, "Failed to pad with specified character")
  }

  func testWrapped() {
    let lipsum = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    for line in lipsum.wrapped(atWidth: 80).split(by: "\n") {
      XCTAssertLessThanOrEqual(line.characters.count, 80, "Failed to wrap long line: \(line)")
    }

    /* Words longer than the wrap width should not be split */
    let longWords = "Lorem ipsum consectetur adipisicing eiusmod tempor incididunt"
    let lines = longWords.wrapped(atWidth: 3).split(by: "\n")
    XCTAssertEqual(lines.count, 8, "Failed to wrap long words")
    for line in lines {
      XCTAssertGreaterThan(line.characters.count, 3, "Bad long word wrapping on line: \(line)")
    }
  }
}
