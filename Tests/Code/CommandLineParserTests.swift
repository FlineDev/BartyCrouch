//
//  CommandLineParserTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouch

class CommandLineParserTests: XCTestCase {
    func testIfCommentCommandIsAdded() {
        CommandLineParser(arguments: ["bartycrouch", "code", "-p", ".", "-l", ".", "--override-comments"]).parse { commonOptions, subCommandOptions in
            switch subCommandOptions {
            case let .codeOptions(_, _, _, overrideComments, _, _, _):
                XCTAssertTrue(overrideComments.value)
            default:
                XCTAssertTrue(false)
            }
        }
        CommandLineParser(arguments: ["bartycrouch", "code", "-p", ".", "-l", ".", "-c"]).parse { commonOptions, subCommandOptions in
            switch subCommandOptions {
            case let .codeOptions(_, _, _, overrideComments, _, _, _):
                XCTAssertTrue(overrideComments.value)
            default:
                XCTAssertTrue(false)
            }
        }
    }

    func testIfCommentCommandIsNotAdded() {
        CommandLineParser(arguments: ["bartycrouch", "translate", "-p", ".", "-i", "no", "-s", "abc", "-l", ".", "--override-comments"]).parse { commonOptions, subCommandOptions in
            switch subCommandOptions {
            case let .codeOptions(_, _, _, overrideComments, _, _, _):
                XCTAssertTrue(!overrideComments.value)
            default:
                XCTAssertTrue(true)
            }
        }
        CommandLineParser(arguments: ["bartycrouch", "translate", "-p", ".", "-i", "no", "-s", "abc", "-l", ".", "-c"]).parse { commonOptions, subCommandOptions in
            switch subCommandOptions {
            case let .codeOptions(_, _, _, overrideComments, _, _, _):
                XCTAssertTrue(!overrideComments.value)
            default:
                XCTAssertTrue(true)
            }
        }
        CommandLineParser(arguments: ["bartycrouch", "interfaces", "-p", ".", "-i", "no", "--override-comments"]).parse { commonOptions, subCommandOptions in
            switch subCommandOptions {
            case let .codeOptions(_, _, _, overrideComments, _, _, _):
                XCTAssertTrue(!overrideComments.value)
            default:
                XCTAssertTrue(true)
            }
        }
        CommandLineParser(arguments: ["bartycrouch", "interfaces", "-p", ".", "-c"]).parse { commonOptions, subCommandOptions in
            switch subCommandOptions {
            case let .codeOptions(_, _, _, overrideComments, _, _, _):
                XCTAssertTrue(!overrideComments.value)
            default:
                XCTAssertTrue(true)
            }
        }
        CommandLineParser(arguments: ["bartycrouch", "code", "-p", ".", "-l", "."]).parse { commonOptions, subCommandOptions in
            switch subCommandOptions {
            case let .codeOptions(_, _, _, overrideComments, _, _, _):
                XCTAssertTrue(!overrideComments.value)
            default:
                XCTAssertTrue(true)
            }
        }
    }
}
