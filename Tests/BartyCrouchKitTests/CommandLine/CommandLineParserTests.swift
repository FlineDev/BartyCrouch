//@testable import BartyCrouchKit
//import XCTest
//
//class CommandLineParserTests: XCTestCase {
//    func testIfCommentCommandIsAdded() {
//        CommandLineParser(arguments: ["bartycrouch", "code", "-p", ".", "-l", ".", "--override-comments"]).parse { _, subCommandOptions in
//            switch subCommandOptions {
//            case let .codeOptions(_, _, _, overrideComments, _, _, _, _, _):
//                XCTAssertTrue(overrideComments.value)
//
//            default:
//                XCTAssertTrue(false)
//            }
//        }
//
//        CommandLineParser(arguments: ["bartycrouch", "code", "-p", ".", "-l", ".", "-c"]).parse { _, subCommandOptions in
//            switch subCommandOptions {
//            case let .codeOptions(_, _, _, overrideComments, _, _, _, _, _):
//                XCTAssertTrue(overrideComments.value)
//
//            default:
//                XCTAssertTrue(false)
//            }
//        }
//    }
//
//    func testIfCommentCommandIsNotAdded() {
//        CommandLineParser(
//            arguments: ["bartycrouch", "translate", "-p", ".", "-i", "no", "-s", "abc", "-l", ".", "--override-comments"]
//        ).parse { _, subCommandOptions in
//            switch subCommandOptions {
//            case let .codeOptions(_, _, _, overrideComments, _, _, _, _, _):
//                XCTAssertTrue(!overrideComments.value)
//
//            default:
//                XCTAssertTrue(true)
//            }
//        }
//
//        CommandLineParser(
//            arguments: ["bartycrouch", "translate", "-p", ".", "-i", "no", "-s", "abc", "-l", ".", "-c"]
//        ).parse { _, subCommandOptions in
//            switch subCommandOptions {
//            case let .codeOptions(_, _, _, overrideComments, _, _, _, _, _):
//                XCTAssertTrue(!overrideComments.value)
//
//            default:
//                XCTAssertTrue(true)
//            }
//        }
//
//        CommandLineParser(
//            arguments: ["bartycrouch", "interfaces", "-p", ".", "-i", "no", "--override-comments"]
//        ).parse { _, subCommandOptions in
//            switch subCommandOptions {
//            case let .codeOptions(_, _, _, overrideComments, _, _, _, _, _):
//                XCTAssertTrue(!overrideComments.value)
//
//            default:
//                XCTAssertTrue(true)
//            }
//        }
//
//        CommandLineParser(
//            arguments: ["bartycrouch", "interfaces", "-p", ".", "-c"]
//        ).parse { _, subCommandOptions in
//            switch subCommandOptions {
//            case let .codeOptions(_, _, _, overrideComments, _, _, _, _, _):
//                XCTAssertTrue(!overrideComments.value)
//
//            default:
//                XCTAssertTrue(true)
//            }
//        }
//
//        CommandLineParser(
//            arguments: ["bartycrouch", "code", "-p", ".", "-l", "."]
//        ).parse { _, subCommandOptions in
//            switch subCommandOptions {
//            case let .codeOptions(_, _, _, overrideComments, _, _, _, _, _):
//                XCTAssertTrue(!overrideComments.value)
//
//            default:
//                XCTAssertTrue(true)
//            }
//        }
//    }
//}
