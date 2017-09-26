/*
 * CommandLineTests.swift
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

internal class CommandLineTests: XCTestCase {
  static var allTests : [(String, (CommandLineTests) -> () throws -> Void)] {
    return [
      ("testBoolOptions", testBoolOptions),
      ("testIntOptions", testIntOptions),
      ("testCounterOptions", testCounterOptions),
      ("testDoubleOptions", testDoubleOptions),
      ("testDoubleOptionsInAlternateLocale", testDoubleOptionsInAlternateLocale),
      ("testStringOptions", testStringOptions),
      ("testMultiStringOptions", testMultiStringOptions),
      ("testConcatOptionWithValue", testConcatOptionWithValue),
      ("testMissingRequiredOption", testMissingRequiredOption),
      ("testAttachedArgumentValues", testAttachedArgumentValues),
      ("testEmojiOptions", testEmojiOptions),
      ("testEnumOption", testEnumOption),
      ("testArgumentStopper", testArgumentStopper),
      ("testFlagStyles", testFlagStyles),
      ("testEmptyFlags", testEmptyFlags),
      ("testDifferentCaseFlagReuse", testDifferentCaseFlagReuse),
      ("testMixedExample", testMixedExample),
      ("testWasSetProperty", testWasSetProperty),
      ("testShortFlagOnlyOption", testShortFlagOnlyOption),
      ("testLongFlagOnlyOption", testLongFlagOnlyOption),
      ("testStrictMode", testStrictMode),
      ("testUnparsedArguments", testUnparsedArguments),
      ("testInvalidArgumentErrorDescription", testInvalidArgumentErrorDescription),
      ("testMissingRequiredOptionsErrorDescription", testMissingRequiredOptionsErrorDescription),
      ("testPrintUsage", testPrintUsage),
      ("testPrintUsageError", testPrintUsageError),
      ("testPrintUsageToStderr", testPrintUsageToStderr),
      ("testCustomOutputFormatter", testCustomOutputFormatter),
    ]
  }

  override func setUp() {
    /* set locale to "C" to start with '.' as the decimal separator */
    setlocale(LC_ALL, "C")
  }

  func testBoolOptions() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a", "--bool", "-c", "-c", "-ddd" ])

    /* Short flag */
    let a = BoolOption(shortFlag: "a", longFlag: "a1", helpMessage: "")

    /* Long flag */
    let b = BoolOption(shortFlag: "b", longFlag: "bool", helpMessage: "")

    /* Multiple flags
     * Do not throw an error if a bool value is specified more than once
     */
    let c = BoolOption(shortFlag: "c", longFlag: "c1", helpMessage: "")

    /* Concatenated multiple flags
     * As with separate multiple flags, don't barf if this happens
     */
    let d = BoolOption(shortFlag: "d", longFlag: "d1", helpMessage: "")

    /* Missing flag */
    let e = BoolOption(shortFlag: "e", longFlag: "e1", helpMessage: "")

    cli.addOptions(a, b, c, d, e)

    do {
      try cli.parse()
      XCTAssertTrue(a.value, "Failed to get true value from short bool")
      XCTAssertTrue(b.value, "Failed to get true value from long bool")
      XCTAssertTrue(c.value, "Failed to get true value from multi-flagged bool")
      XCTAssertTrue(d.value, "Failed to get true value from concat multi-flagged bool")
      XCTAssertFalse(e.value, "Failed to get false value from missing bool")
    } catch {
      XCTFail("Failed to parse bool options: \(error)")
    }
  }

  func testIntOptions() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a", "1", "--bigs", "2", "-c", "3",
      "-c", "4", "-ddd", "-e", "bad", "-f", "-g", "-5" ])

    /* Short flag */
    let a = IntOption(shortFlag: "a", longFlag: "a1", required: false, helpMessage: "")

    /* Long flag */
    let b = IntOption(shortFlag: "b", longFlag: "bigs", required: false, helpMessage: "")

    /* Multiple short flags
     * If an int is specified multiple times, return the last (rightmost) value
     */
    let c = IntOption(shortFlag: "c", longFlag: "c1", required: false, helpMessage: "")

    cli.addOptions(a, b, c)

    do {
      try cli.parse()
      XCTAssertEqual(a.value, 1, "Failed to get correct value from short int")
      XCTAssertEqual(b.value, 2, "Failed to get correct value from long int")
      XCTAssertEqual(c.value, 4, "Failed to get correct value from multi-flagged int")
    } catch {
      XCTFail("Failed to parse int options: \(error)")
    }

    /* Concatenated multiple flags
     * Concat flags can't have values
     */
    let d = IntOption(shortFlag: "d", longFlag: "d1", required: false, helpMessage: "")
    cli.setOptions(d)

    do {
      try cli.parse()
      XCTFail("Parsed invalid concat int option")
    } catch {
      XCTAssertNil(d.value, "Got non-nil value from concat multi-flagged int")
    }

    /* Non-int value */
    let e = IntOption(shortFlag: "e", longFlag: "e1", required: false, helpMessage: "")
    cli.setOptions(e)

    do {
      try cli.parse()
      XCTFail("Parsed invalid int option")
    } catch let CommandLineKit.CommandLine.ParseError.invalidValueForOption(opt, vals) {
      XCTAssert(opt === e, "Incorrect option in ParseError: \(opt.longFlag)")
      XCTAssertEqual(vals, ["bad"], "Incorrect values in ParseError: \(vals)")
      XCTAssertNil(e.value, "Got non-nil value from invalid int")
    } catch {
      XCTFail("Unexpected parse error: \(error)")
    }

    /* No value */
    let f = IntOption(shortFlag: "f", longFlag: "f1", required: false, helpMessage: "")
    cli.setOptions(f)

    do {
      try cli.parse()
      XCTFail("Parsed int option with no value")
    } catch let CommandLineKit.CommandLine.ParseError.invalidValueForOption(opt, vals) {
      XCTAssert(opt === f, "Incorrect option in ParseError: \(opt.longFlag)")
      XCTAssertEqual(vals, [], "Incorrect values in ParseError: \(vals)")
      XCTAssertNil(f.value, "Got non-nil value from no value int")
    } catch {
      XCTFail("Unexpected parse error: \(error)")
    }

    /* Negative int */
    let g = IntOption(shortFlag: "g", longFlag: "g1", required: false, helpMessage: "")
    cli.setOptions(g)

    do {
      try cli.parse()
      XCTAssertEqual(g.value, -5, "Failed to get correct value from int option with negative value")
    } catch {
      XCTFail("Failed to parse int option with negative value: \(error)")
    }
  }

  func testCounterOptions() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a", "--bach", "-c", "-c",
      "--doggerel", "-doggerel", "--doggerel", "-eeee"])

    /* Short flag */
    let a = CounterOption(shortFlag: "a", longFlag: "a1", helpMessage: "")

    /* Long flag */
    let b = CounterOption(shortFlag: "b", longFlag: "bach", helpMessage: "")

    /* Multiple short flags
     * If a double is specified multiple times, return the last (rightmost) value
     */
    let c = CounterOption(shortFlag: "c", longFlag: "c1", helpMessage: "")

    /* Multiple long flags */
    let d = CounterOption(shortFlag: "d", longFlag: "doggerel", helpMessage: "")

    /* Concatenated multiple flags */
    let e = CounterOption(shortFlag: "e", longFlag: "e1", helpMessage: "")

    /* Unspecified option should return 0, not nil */
    let f = CounterOption(shortFlag: "f", longFlag: "f1", helpMessage: "")

    cli.addOptions(a, b, c, d, e, f)

    do {
      try cli.parse()
      XCTAssertEqual(a.value, 1, "Failed to get correct value from short counter")
      XCTAssertEqual(b.value, 1, "Failed to get correct value from long counter")
      XCTAssertEqual(c.value, 2, "Failed to get correct value from multi-flagged short counter")
      XCTAssertEqual(d.value, 3, "Failed to get correct value from multi-flagged long counter")
      XCTAssertEqual(e.value, 4, "Failed to get correct value from concat multi-flagged counter")
      XCTAssertEqual(f.value, 0, "Failed to get correct value from unspecified counter")
    } catch {
      XCTFail("Failed to parse counter options: \(error)")
    }
  }

  func testDoubleOptions() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a", "1.4", "--baritone", "2.5",
      "-c", "5.0", "-c", "5.2", "--dingus", "8.5", "--dingus", "8.8", "-e", "95",
      "-f", "bad", "-g", "-h", "-3.14159" ])

    setlocale(LC_ALL, "C")

    /* Short flag */
    let a = DoubleOption(shortFlag: "a", longFlag: "a1", required: true, helpMessage: "")

    /* Long flag */
    let b = DoubleOption(shortFlag: "b", longFlag: "baritone", required: true, helpMessage: "")

    /* Multiple short flags */
    let c = DoubleOption(shortFlag: "c", longFlag: "c1", required: true, helpMessage: "")

    /* Multiple long flags */
    let d = DoubleOption(shortFlag: "d", longFlag: "dingus", required: true, helpMessage: "")

    /* Integer value */
    let e = DoubleOption(shortFlag: "e", longFlag: "e1", required: true, helpMessage: "")

    cli.addOptions(a, b, c, d, e)

    do {
      try cli.parse()
      XCTAssertEqual(a.value, 1.4, "Failed to get correct value from short double")
      XCTAssertEqual(b.value, 2.5, "Failed to get correct value from long double")
      XCTAssertEqual(c.value, 5.2, "Failed to get correct value from multi-flagged short double")
      XCTAssertEqual(d.value, 8.8, "Failed to get correct value from multi-flagged long double")
      XCTAssertEqual(e.value, 95.0, "Failed to get correct double value from integer argument")
    } catch {
      XCTFail("Failed to parse double options: \(error)")
    }

    /* Non-double value */
    let f = DoubleOption(shortFlag: "f", longFlag: "f1", required: true, helpMessage: "")
    cli.setOptions(f)

    do {
      try cli.parse()
      XCTFail("Parsed invalid double option")
    } catch let CommandLineKit.CommandLine.ParseError.invalidValueForOption(opt, vals) {
      XCTAssert(opt === f, "Incorrect option in ParseError: \(opt.longFlag)")
      XCTAssertEqual(vals, ["bad"], "Incorrect values in ParseError: \(vals)")
      XCTAssertNil(f.value, "Got non-nil value from invalid double")
    } catch {
      XCTFail("Unexpected parse error: \(error)")
    }


    /* No value */
    let g = DoubleOption(shortFlag: "g", longFlag: "g1", required: true, helpMessage: "")
    cli.setOptions(g)

    do {
      try cli.parse()
      XCTFail("Parsed double option with no value")
    } catch let CommandLineKit.CommandLine.ParseError.invalidValueForOption(opt, vals) {
      XCTAssert(opt === g, "Incorrect option in ParseError: \(opt.longFlag)")
      XCTAssertEqual(vals, [], "Incorrect values in ParseError: \(vals)")
      XCTAssertNil(g.value, "Got non-nil value from no value double")
    } catch {
      XCTFail("Unexpected parse error: \(error)")
    }

    /* Negative double */
    let h = DoubleOption(shortFlag: "h", longFlag: "h1", required: true, helpMessage: "")
    cli.setOptions(h)

    do {
      try cli.parse()
      XCTAssertEqual(h.value, -3.14159, "Failed to get correct value from double with negative value")
    } catch {
      XCTFail("Failed to parse double option with negative value: \(error)")
    }
  }

  func testDoubleOptionsInAlternateLocale() {
    let cli = CommandLine(arguments: ["CommandLineTests", "-a", "3,14159"])
    let a = DoubleOption(shortFlag: "a", longFlag: "a1", required: true, helpMessage: "")

    cli.addOptions(a)

    setlocale(LC_ALL, "sv_SE.UTF-8")

    do {
      try cli.parse()
      XCTAssertEqual(a.value, 3.14159, "Failed to get correct value from double in alternate locale")
    } catch {
      XCTFail("Failed to parse double options in alternate locale: \(error)")
    }
  }

  func testStringOptions() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a", "one", "--b1", "two", "-c", "x", "-c", "xx",
      "--d1", "y", "--d1", "yy", "-e" ])

    /* Short flag */
    let a = StringOption(shortFlag: "a", longFlag: "a1", required: true, helpMessage: "")

    /* Long flag */
    let b = StringOption(shortFlag: "b", longFlag: "b1", required: true, helpMessage: "")

    /* Multiple short flags */
    let c = StringOption(shortFlag: "c", longFlag: "c1", required: true, helpMessage: "")

    /* Multiple long flags */
    let d = StringOption(shortFlag: "d", longFlag: "d1", required: true, helpMessage: "")

    cli.addOptions(a, b, c, d)

    do {
      try cli.parse()
      XCTAssertEqual(a.value, "one", "Failed to get correct value from short string")
      XCTAssertEqual(b.value, "two", "Failed to get correct value from long string")
      XCTAssertEqual(c.value, "xx", "Failed to get correct value from multi-flagged short string")
      XCTAssertEqual(d.value, "yy", "Failed to get correct value from multi-flagged long string")
    } catch {
      XCTFail("Failed to parse string options: \(error)")
    }

    /* No value */
    let e = StringOption(shortFlag: "e", longFlag: "e1", required: false, helpMessage: "")
    cli.setOptions(e)

    do {
      try cli.parse()
      XCTFail("Parsed string option with no value")
    } catch let CommandLineKit.CommandLine.ParseError.invalidValueForOption(opt, vals) {
      XCTAssert(opt === e, "Incorrect option in ParseError: \(opt.longFlag)")
      XCTAssertEqual(vals, [], "Incorrect values in ParseError: \(vals)")
      XCTAssertNil(e.value, "Got non-nil value from no value string")
    } catch {
      XCTFail("Unexpected parse error: \(error)")
    }
  }

  func testMultiStringOptions() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a", "one", "-b", "two", "2wo",
      "--c1", "three", "--d1", "four", "4our", "-e" ])

    /* Short flags */
    let a = MultiStringOption(shortFlag: "a", longFlag: "a1", required: true, helpMessage: "")
    let b = MultiStringOption(shortFlag: "b", longFlag: "b1", required: true, helpMessage: "")

    /* Long flags */
    let c = MultiStringOption(shortFlag: "c", longFlag: "c1", required: true, helpMessage: "")
    let d = MultiStringOption(shortFlag: "d", longFlag: "d1", required: true, helpMessage: "")

    cli.addOptions(a, b, c, d)

    do {
      try cli.parse()
      XCTAssertEqual(a.value?.count, 1, "Failed to get correct number of values from single short multistring")
      XCTAssertEqual(a.value?[0], "one", "Filed to get correct value from single short multistring")
      XCTAssertEqual(b.value?.count, 2, "Failed to get correct number of values from multi short multistring")
      XCTAssertEqual(b.value?[0], "two", "Failed to get correct first value from multi short multistring")
      XCTAssertEqual(b.value?[1], "2wo", "Failed to get correct second value from multi short multistring")
      XCTAssertEqual(c.value?.count, 1, "Failed to get correct number of values from single long multistring")
      XCTAssertEqual(c.value?[0], "three", "Filed to get correct value from single long multistring")
      XCTAssertEqual(d.value?.count, 2, "Failed to get correct number of values from multi long multistring")
      XCTAssertEqual(d.value?[0], "four", "Failed to get correct first value from multi long multistring")
      XCTAssertEqual(d.value?[1], "4our", "Failed to get correct second value from multi long multistring")
    } catch {
      XCTFail("Failed to parse multi string options: \(error)")
    }

    /* No value */
    let e = MultiStringOption(shortFlag: "e", longFlag: "e1", required: false, helpMessage: "")
    cli.setOptions(e)

    do {
      try cli.parse()
      XCTFail("Parsed multi string option with no value")
    } catch let CommandLineKit.CommandLine.ParseError.invalidValueForOption(opt, vals) {
      XCTAssert(opt === e, "Incorrect option in ParseError: \(opt.longFlag)")
      XCTAssertEqual(vals, [], "Incorrect values in ParseError: \(vals)")
      XCTAssertNil(e.value, "Got non-nil value from no value multistring")
    } catch {
      XCTFail("Unexpected parse error: \(error)")
    }
  }

  func testConcatOptionWithValue() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-xvf", "file1", "file2" ])

    let x = BoolOption(shortFlag: "x", longFlag: "x1", helpMessage: "")
    let v = CounterOption(shortFlag: "v", longFlag: "v1", helpMessage: "")
    let f = MultiStringOption(shortFlag: "f", longFlag: "file", required: true, helpMessage: "")

    cli.addOptions(x, v, f)

    do {
      try cli.parse()
      XCTAssertTrue(x.value as Bool, "Failed to get true value from concat flags with value")
      XCTAssertEqual(v.value, 1, "Failed to get correct value from concat flags with value")
      XCTAssertEqual(f.value?.count, 2, "Failed to get values from concat flags with value")
      XCTAssertEqual(f.value?[0], "file1", "Failed to get first value from concat flags with value")
      XCTAssertEqual(f.value?[1], "file2", "Failed to get second value from concat flags with value")
    } catch {
      XCTFail("Failed to parse concat flags with value: \(error)")
    }
  }

  func testMissingRequiredOption() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a", "-b", "foo", "-q", "quux" ])
    let c = StringOption(shortFlag: "c", longFlag: "c1", required: true, helpMessage: "")

    cli.addOption(c)

    do {
      try cli.parse()
      XCTFail("Parsed missing required option")
    } catch let CommandLineKit.CommandLine.ParseError.missingRequiredOptions(opts) {
      XCTAssert(opts[0] === c, "Failed to identify missing required options: \(opts)")
      XCTAssertNil(c.value, "Got non-nil value from missing option")
    } catch {
      XCTFail("Unexpected parse error: \(error)")
    }
  }

  func testAttachedArgumentValues() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a=5", "--bb=klaxon" ])

    let a = IntOption(shortFlag: "a", longFlag: "a1", required: true, helpMessage: "")
    let b = StringOption(shortFlag: "b", longFlag: "bb", required: true, helpMessage: "")

    cli.addOptions(a, b)

    do {
      try cli.parse()
      XCTAssertEqual(a.value, 5, "Failed to get correct int attached value")
      XCTAssertEqual(b.value, "klaxon", "Failed to get correct string attached value")
    } catch {
      XCTFail("Failed to parse attached argument values: \(error)")
    }
  }

  func testEmojiOptions() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-👻", "3", "--👍", "☀️" ])

    let a = IntOption(shortFlag: "👻", longFlag: "👻", required: true, helpMessage: "")
    let b = StringOption(shortFlag: "👍", longFlag: "👍", required: true, helpMessage: "")


    cli.addOptions(a, b)

    do {
      try cli.parse()
      XCTAssertEqual(a.value, 3)
      XCTAssertEqual(b.value, "☀️")
    } catch {
      XCTFail("Failed to parse emoji options: \(error)")
    }
  }

  func testEnumOption() {
    enum Operation: String {
      case create = "c"
      case extract = "x"
      case list = "l"
      case verify = "v"
    }

    let cli = CommandLine(arguments: [ "CommandLineTests", "--operation", "x" ])
    let op = EnumOption<Operation>(shortFlag: "o", longFlag: "operation", required: true, helpMessage: "")

    cli.setOptions(op)

    do {
      try cli.parse()
      XCTAssertEqual(op.value, Operation.extract, "Failed to get correct value from enum option")
    } catch {
      XCTFail("Failed to parse enum options: \(error)")
    }
  }

  func testArgumentStopper() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a", "--", "-value", "--", "-55" ])
    let op = MultiStringOption(shortFlag: "a", longFlag: "a1", required: true, helpMessage: "")

    cli.setOptions(op)

    do {
      try cli.parse()
      XCTAssertEqual(op.value?.count, 3, "Failed to get correct number of options with stopper")
      XCTAssertEqual(op.value?[0], "-value", "Failed to get correct value from options with stopper")
      XCTAssertEqual(op.value?[1], "--", "Failed to get correct value from options with stopper")
      XCTAssertEqual(op.value?[2], "-55", "Failed to get correct value from options with stopper")
    } catch {
      XCTFail("Failed to parse options with an argument stopper: \(error)")
    }
  }

  func testFlagStyles() {
    let argLines = [
      [ "CommandLineTests", "-xvf", "/path/to/file" ],
      [ "CommandLineTests", "-x", "-v", "-f", "/path/to/file" ],
      [ "CommandLineTests", "-x", "--verbose", "--file", "/path/to/file" ],
      [ "CommandLineTests", "-xv", "--file", "/path/to/file" ],
      [ "CommandLineTests", "--extract", "-v", "--file=/path/to/file" ]
    ]

    for args in argLines {
      let cli = CommandLine(arguments: args)
      let extract = BoolOption(shortFlag: "x", longFlag: "extract", helpMessage: "")
      let verbosity = CounterOption(shortFlag: "v", longFlag: "verbose", helpMessage: "")
      let filePath = StringOption(shortFlag: "f", longFlag: "file", required: true, helpMessage: "")

      cli.setOptions(extract, verbosity, filePath)

      do {
        try cli.parse()
        XCTAssertEqual(extract.value, true, "Failed to parse extract value from arg line \(args)")
        XCTAssertEqual(verbosity.value, 1, "Failed to parse verbosity value from arg line \(args)")
        XCTAssertEqual(filePath.value, "/path/to/file", "Failed to parse file path value from arg line \(args)")
      } catch {
        XCTFail("Failed to parse arg line \(args): \(error)")
      }
    }
  }

  func testEmptyFlags() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-", "--"])

    do {
      try cli.parse()
    } catch {
      XCTFail("Failed to parse empty flags: \(error)")
    }
  }

  /* These three tests should assert() in cli.addOption, but there's no clean way to test for
   * assertions in Swift 2, so they're commented out for now.
   */

  /*
  func testShortFlagReuse() {
    let cli = CommandLine(arguments: [])
    let op1 = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "")
    let op2 = StringOption(shortFlag: "v", longFlag: "verify", helpMessage: "")
    cli.addOptions(op1, op2)
    XCTFail("Added two options with the same short flag")
  }

  func testLongFlagReuse() {
    let cli = CommandLine(arguments: [])
    let op1 = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "")
    let op2 = StringOption(shortFlag: "d", longFlag: "verbose", helpMessage: "")
    cli.addOptions(op1, op2)
    XCTFail("Added two options with the same long flag")
  }

  func testSetOptionFlagReuse() {
    let cli = CommandLine(arguments: [])
    let opts = [
      BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: ""),
      StringOption(shortFlag: "v", longFlag: "verify", helpMessage: "")
    ]

    cli.setOptions(opts)
    XCTFail("Set options to an array with a reused flag")
  }
  */

  func testDifferentCaseFlagReuse() {
    let cli = CommandLine(arguments: [])
    let op1 = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "")
    let op2 = StringOption(shortFlag: "V", longFlag: "verify", helpMessage: "")
    cli.addOptions(op1, op2)
  }

  func testMixedExample() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-dvvv", "--name", "John Q. Public",
      "-f", "45", "-p", "0.05", "-x", "extra1", "extra2", "extra3" ])

    setlocale(LC_ALL, "C")

    let boolOpt = BoolOption(shortFlag: "d", longFlag: "debug", helpMessage: "Enables debug mode.")
    let counterOpt = CounterOption(shortFlag: "v", longFlag: "verbose",
      helpMessage: "Enables verbose output. Specify multiple times for extra verbosity.")
    let stringOpt = StringOption(shortFlag: "n", longFlag: "name", required: true,
      helpMessage: "Name a Cy Young winner.")
    let intOpt = IntOption(shortFlag: "f", longFlag: "favorite", required: true,
      helpMessage: "Your favorite number.")
    let doubleOpt = DoubleOption(shortFlag: "p", longFlag: "p-value", required: true,
      helpMessage: "P-value for test.")
    let extraOpt = MultiStringOption(shortFlag: "x", longFlag: "Extra", required: true,
      helpMessage: "X is for Extra.")

    cli.addOptions(boolOpt, counterOpt, stringOpt, intOpt, doubleOpt, extraOpt)

    do {
      try cli.parse()
      XCTAssertTrue(boolOpt.value, "Failed to get correct bool value from mixed command line")
      XCTAssertEqual(counterOpt.value, 3, "Failed to get correct counter value from mixed command line")
      XCTAssertEqual(stringOpt.value, "John Q. Public", "Failed to get correct string value from mixed command line")
      XCTAssertEqual(intOpt.value, 45, "Failed to get correct int value from mixed command line")
      XCTAssertEqual(doubleOpt.value, 0.05, "Failed to get correct double value from mixed command line")
      XCTAssertEqual(extraOpt.value?.count  , 3, "Failed to get correct number of multistring options from mixed command line")
    } catch {
      XCTFail("Failed to parse mixed command line: \(error)")
    }
  }

  func testWasSetProperty() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-a", "-b", "-c", "str", "-d", "1",
      "-e", "3.14159", "-f", "extra1", "extra2", "extra3" ])

    setlocale(LC_ALL, "C")

    let setOptions = [
      BoolOption(shortFlag: "a", longFlag: "bool", helpMessage: "A set boolean option"),
      CounterOption(shortFlag: "b", longFlag: "counter", helpMessage: "A set counter option"),
      StringOption(shortFlag: "c", longFlag: "str", helpMessage: "A set string option"),
      IntOption(shortFlag: "d", longFlag: "int", helpMessage: "A set int option"),
      DoubleOption(shortFlag: "e", longFlag: "double", helpMessage: "A set double option"),
      MultiStringOption(shortFlag: "f", longFlag: "multi", helpMessage: "A set multistring option")
    ]

    let unsetOptions = [
      BoolOption(shortFlag: "t", longFlag: "unbool", helpMessage: "An unset boolean option"),
      CounterOption(shortFlag: "v", longFlag: "uncounter", helpMessage: "An unset counter option"),
      StringOption(shortFlag: "w", longFlag: "unstr", helpMessage: "An unset string option"),
      IntOption(shortFlag: "y", longFlag: "unint", helpMessage: "An unset int option"),
      DoubleOption(shortFlag: "x", longFlag: "undouble", helpMessage: "An unset double option"),
      MultiStringOption(shortFlag: "z", longFlag: "unmulti", helpMessage: "An unset multistring option")
    ]

    cli.addOptions(setOptions)
    cli.addOptions(unsetOptions)

    do {
      try cli.parse()
      for opt in setOptions {
        XCTAssertTrue(opt.wasSet, "wasSet was false for set option \(opt.flagDescription)")
      }
      for opt in unsetOptions {
        XCTAssertFalse(opt.wasSet, "wasSet was true for unset option \(opt.flagDescription)")
      }
    } catch {
      XCTFail("Failed to parse command line with set & unset options: \(error)")
    }
  }

  func testShortFlagOnlyOption() {
    let cli = CommandLine(arguments: ["-s", "itchy", "--itchy", "scratchy"])

    let o1 = StringOption(shortFlag: "s", helpMessage: "short only")
    let o2 = StringOption(shortFlag: "i", helpMessage: "another short")
    cli.addOptions(o1, o2)

    do {
      try cli.parse()
      XCTAssertEqual(o1.value, "itchy", "Failed to get correct string value from short-flag-only option")
      XCTAssertNil(o2.value, "Incorrectly set value for short-flag-only option")
    } catch {
      XCTFail("Failed to parse short-flag-only command line: \(error)")
    }
  }

  func testLongFlagOnlyOption() {
    let cli = CommandLine(arguments: ["-s", "itchy", "--itchy", "scratchy"])

    let o1 = StringOption(longFlag: "scratchy", helpMessage: "long only")
    let o2 = StringOption(longFlag: "itchy", helpMessage: "long short")
    cli.addOptions(o1, o2)

    do {
      try cli.parse()
      XCTAssertNil(o1.value, "Incorrectly set value for long-flag-only option")
      XCTAssertEqual(o2.value, "scratchy", "Failed to get correct string value from long-flag-only option")
    } catch {
      XCTFail("Failed to parse long-flag-only command line: \(error)")
    }
  }

  func testStrictMode() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "--valid", "--invalid"])
    let validOpt = BoolOption(shortFlag: "v", longFlag: "valid", helpMessage: "Known flag.")
    cli.addOptions(validOpt)

    do {
      try cli.parse()
    } catch {
      XCTFail("Failed to parse invalid flags in non-strict mode")
    }

    do {
      try cli.parse(strict: true)
      XCTFail("Successfully parsed invalid flags in strict mode")
    } catch let CommandLineKit.CommandLine.ParseError.invalidArgument(arg) {
      XCTAssertEqual(arg, "--invalid", "Incorrect argument identified in InvalidArgument: \(arg)")
    } catch {
      XCTFail("Unexpected parse error: \(error)")
    }
  }

  func testUnparsedArguments() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "onefish", "twofish", "-b", "redfish", "-c", "green", "blue", "-xvvi", "9", "-w", "--who", "--formats=json", "xml", "binary", "--verbose", "fish", "--type=pdf", "woo!"])
    let o1 = BoolOption(shortFlag: "b", longFlag: "bool", helpMessage: "Boolean option")
    let o2 = StringOption(shortFlag: "c", longFlag: "color", helpMessage: "String option")
    let o3 = BoolOption(shortFlag: "x", longFlag: "extract", helpMessage: "Combined bool option")
    let o4 = CounterOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Combined counter option")
    let o5 = IntOption(shortFlag: "i", longFlag: "int", helpMessage: "Combined int option")
    let o6 = MultiStringOption(shortFlag: "f", longFlag: "formats", helpMessage: "Attached multistring option")
    let o7 = StringOption(shortFlag: "t", longFlag: "type", helpMessage: "Attached string option")

    cli.addOptions(o1, o2, o3, o4, o5, o6, o7)

    do {
      try cli.parse()
      XCTAssertTrue(o1.value, "Failed to set bool option with stray values")
      XCTAssertEqual(o2.value, "green", "Incorrect value for string option with stray values")
      XCTAssertTrue(o3.value, "Failed to set combined bool option with stray values")
      XCTAssertEqual(o4.value, 3, "Incorrect value for combined counter option with stray values")
      XCTAssertEqual(o5.value, 9, "Incorrect value for combined int option with stray values")
      XCTAssertEqual(o6.value ?? [], ["json", "xml", "binary"], "Incorrect value for attached multistring option with stray values")
      XCTAssertEqual(o7.value, "pdf", "Incorrect value for attached string option with stray values")
      XCTAssertEqual(cli.unparsedArguments, ["onefish", "twofish", "redfish", "blue", "-w", "--who", "fish", "woo!"], "Incorrect unparsed values")
    } catch {
      XCTFail("Unexpected parse error: \(error)")
    }

    do {
      let cli = CommandLine(arguments: [ "CommandLineTests", "onefish", "twofish", "-b", "redfish", "-c", "green", "blue", "-xvvi", "9", "--formats=json", "xml", "binary", "--verbose", "fish", "--type=pdf", "woo!"])
      o4.reset()
      cli.addOptions(o1, o2, o3, o4, o5, o6, o7)

      try cli.parse(strict: true)
      XCTAssertTrue(o1.value, "Failed to set bool option with stray values")
      XCTAssertEqual(o2.value, "green", "Incorrect value for string option with stray values")
      XCTAssertTrue(o3.value, "Failed to set combined bool option with stray values")
      XCTAssertEqual(o4.value, 3, "Incorrect value for combined counter option with stray values")
      XCTAssertEqual(o5.value, 9, "Incorrect value for combined int option with stray values")
      XCTAssertEqual(o6.value ?? [], ["json", "xml", "binary"], "Incorrect value for attached multistring option with stray values")
      XCTAssertEqual(o7.value, "pdf", "Incorrect value for attached string option with stray values")
      XCTAssertEqual(cli.unparsedArguments, ["onefish", "twofish", "redfish", "blue", "fish", "woo!"], "Incorrect unparsed values")
    } catch {
      XCTFail("Stray values should not cause a throw in strict mode")
    }
  }

  func testInvalidArgumentErrorDescription() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "--int", "invalid"])
    let o1 = IntOption(longFlag: "int", helpMessage: "Int flag.")
    cli.addOptions(o1)

    do {
      try cli.parse()
    } catch {
      XCTAssertTrue("\(error)".hasSuffix("\(o1.flagDescription): invalid"), "Invalid error description: \(error)")
    }
  }

  func testMissingRequiredOptionsErrorDescription() {
    let cli = CommandLine(arguments: [ "CommandLineTests"])
    let o1 = IntOption(longFlag: "int", required: true, helpMessage: "Int flag.")
    cli.addOptions(o1)

    do {
      try cli.parse()
    } catch {
      let requiredOptions = [o1].map { return $0.flagDescription }
      XCTAssertTrue("\(error)".hasSuffix("options: \(requiredOptions)"), "Invalid error description: \(error)")
    }
  }

  func testPrintUsage() {
    let cli = CommandLine(arguments: [ "CommandLineTests", "-dvvv", "--name", "John Q. Public",
      "-f", "45", "-p", "0.05", "-x", "extra1", "extra2", "extra3" ])

    let boolOpt = BoolOption(shortFlag: "d", longFlag: "debug", helpMessage: "Enables debug mode.")
    let counterOpt = CounterOption(shortFlag: "v", longFlag: "verbose",
      helpMessage: "Enables verbose output. Specify multiple times for extra verbosity.")
    let stringOpt = StringOption(shortFlag: "n", longFlag: "name", required: true,
      helpMessage: "Name a Cy Young winner.")
    let intOpt = IntOption(shortFlag: "f", longFlag: "favorite", required: true,
      helpMessage: "Your favorite number.")
    let doubleOpt = DoubleOption(shortFlag: "p", longFlag: "p-value", required: true,
      helpMessage: "P-value for test.")
    let extraOpt = MultiStringOption(shortFlag: "x", longFlag: "Extra", required: true,
      helpMessage: "X is for Extra.")

    let opts = [boolOpt, counterOpt, stringOpt, intOpt, doubleOpt, extraOpt]
    cli.addOptions(opts)

    var out = ""
    cli.printUsage(&out)
    XCTAssertGreaterThan(out.characters.count, 0)

    /* There should be at least 2 lines per option, plus the intro Usage statement */
    XCTAssertGreaterThanOrEqual(out.split(by: "\n").count, (opts.count * 2) + 1)
  }

  func testPrintUsageError() {
    let cli = CommandLine(arguments: [ "CommandLineTests" ])
    cli.addOption(StringOption(shortFlag: "n", longFlag: "name", required: true,
      helpMessage: "Your name"))

    do {
      try cli.parse()
      XCTFail("Didn't throw with missing required argument")
    } catch {
      var out = ""
      cli.printUsage(error, to: &out)

      let errorMessage = out.split(by: "\n", maxSplits: 1)[0]
      XCTAssertTrue(errorMessage.hasPrefix("Missing required"))
    }
  }

  func testPrintUsageToStderr() {
    let cli = CommandLine(arguments: [ "CommandLineTests" ])
    cli.addOption(StringOption(shortFlag: "n", longFlag: "name", required: true,
      helpMessage: "Your name"))

    /* Toss stderr into /dev/null, so the printUsage() output doesn't pollute regular
     * XCTest messages.
     */
    let origStdErr = dup(fileno(stderr))
    let null = fopen("/dev/null", "w")
    dup2(fileno(null), fileno(stderr))

    defer {
      dup2(origStdErr, fileno(stderr))
      fclose(null)
    }

    let error = CommandLine.ParseError.invalidArgument("ack")

    /* Just make sure these doesn't crash or throw */
    cli.printUsage()
    cli.printUsage(error)
  }

  func testCustomOutputFormatter() {
    let cli = CommandLine(arguments: [ "CommandLineTests" ])
    cli.formatOutput = { s, type in
      switch type {
      case .about:
        return "[ABOUT]\(s)\n"
      case .error:
        return "[ERROR]\(s)\n"
      case .optionFlag:
        return "[FLAG]\(s)\n"
      case .optionHelp:
        return "[HELP]\(s)\n"
      }
    }

    let boolOpt = BoolOption(shortFlag: "d", longFlag: "debug", helpMessage: "Enables debug mode.")
    let counterOpt = CounterOption(shortFlag: "v", longFlag: "verbose",
      helpMessage: "Enables verbose output. Specify multiple times for extra verbosity.")
    let stringOpt = StringOption(shortFlag: "n", longFlag: "name", required: true,
      helpMessage: "Name a Cy Young winner.")
    let intOpt = IntOption(shortFlag: "f", longFlag: "favorite", required: true,
      helpMessage: "Your favorite number.")
    let doubleOpt = DoubleOption(shortFlag: "p", longFlag: "p-value", required: true,
      helpMessage: "P-value for test.")
    let extraOpt = MultiStringOption(shortFlag: "x", longFlag: "Extra", required: true,
      helpMessage: "X is for Extra.")

    let opts = [boolOpt, counterOpt, stringOpt, intOpt, doubleOpt, extraOpt]
    cli.addOptions(opts)

    do {
      try cli.parse()
      XCTFail("Parsed missing required option")
    } catch {
      var out = ""
      cli.printUsage(error, to: &out)

      let o = out.split(by: "\n")
      XCTAssertTrue(o[0].hasPrefix("[ERROR]"))
      XCTAssertTrue(o[1].hasPrefix("[ABOUT]"))

      let range = stride(from: 2, to: opts.count, by: 2)
      for i in range {
        XCTAssertTrue(o[i].hasPrefix("[FLAG]"))
        XCTAssertTrue(o[i + 1].hasPrefix("[HELP]"))
      }
    }
  }
}
