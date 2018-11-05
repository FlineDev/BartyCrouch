//
//  Created by Frederick Pietschmann on 18.04.18.
//  Copyright © 2018 Flinesoft. All rights reserved.
//

import Foundation

@testable import HandySwift
import XCTest

class RegexTests: XCTestCase {
    // MARK: - Initialization
    func testValidInitialization() {
        XCTAssertNoThrow({ try Regex("abc") }) // swiftlint:disable:this trailing_closure
    }

    func testInvalidInitialization() {
       do {
            _ = try Regex("*")
            XCTFail("Regex initialization unexpectedly didn't fail")
        } catch {
        }
    }

    // MARK: - Options
    func testOptions() {
        let regexOptions1: Regex.Options = [.ignoreCase, .ignoreMetacharacters, .anchorsMatchLines, .dotMatchesLineSeparators]
        let nsRegexOptions1: NSRegularExpression.Options = [.caseInsensitive, .ignoreMetacharacters, .anchorsMatchLines, .dotMatchesLineSeparators]

        let regexOptions2: Regex.Options = [.ignoreMetacharacters]
        let nsRegexOptions2: NSRegularExpression.Options = [.ignoreMetacharacters]

        let regexOptions3: Regex.Options = []
        let nsRegexOptions3: NSRegularExpression.Options = []

        XCTAssertEqual(regexOptions1.toNSRegularExpressionOptions, nsRegexOptions1)
        XCTAssertEqual(regexOptions2.toNSRegularExpressionOptions, nsRegexOptions2)
        XCTAssertEqual(regexOptions3.toNSRegularExpressionOptions, nsRegexOptions3)
    }

    // MARK: - Matching
    func testMatchesBool() {
        let regex = try? Regex("[1-9]+")
        XCTAssertTrue(regex!.matches("5"))
    }

    func testFirstMatch() {
        let regex = try? Regex("[1-9]?+")
        XCTAssertEqual(regex?.firstMatch(in: "5 3 7")?.string, "5")
    }

    func testMatches() {
        let regex = try? Regex("[1-9]+")
        XCTAssertEqual(regex?.matches(in: "5 432 11").map { $0.string }, ["5", "432", "11"])
    }

    func testReplacingMatches() {
        let regex = try? Regex("([1-9]+)")

        let stringAfterReplace1 = regex?.replacingMatches(in: "5 3 7", with: "2")
        let stringAfterReplace2 = regex?.replacingMatches(in: "5 3 7", with: "$1")
        let stringAfterReplace3 = regex?.replacingMatches(in: "5 3 7", with: "1$1,")
        let stringAfterReplace4 = regex?.replacingMatches(in: "5 3 7", with: "2", count: 5)
        let stringAfterReplace5 = regex?.replacingMatches(in: "5 3 7", with: "2", count: 2)

        XCTAssertEqual(stringAfterReplace1, "2 2 2")
        XCTAssertEqual(stringAfterReplace2, "5 3 7")
        XCTAssertEqual(stringAfterReplace3, "15, 13, 17,")
        XCTAssertEqual(stringAfterReplace4, "2 2 2")
        XCTAssertEqual(stringAfterReplace5, "2 2 7")
    }

    func testReplacingMatchesWithSpecialCharacters() {
        let testString = "\n<string name=\"nav_menu_sim_info\">Simuliere, wie gut ein \\nE-Fahrzeug zu dir passt</string>\n"
        let newValue = "Simuliere, wie gut ein \\nE-Fahrzeug zu dir passt2"
        let expectedResult = "\n<string name=\"nav_menu_sim_info\">Simuliere, wie gut ein \\nE-Fahrzeug zu dir passt2</string>\n"

        let regex = try? Regex("(<string[^>]* name=\"nav_menu_sim_info\"[^>]*>)(.*)(</string>)")
        let stringAfterReplace1 = regex?.replacingMatches(in: testString, with: "$1\(NSRegularExpression.escapedTemplate(for: newValue))$3")

        XCTAssertEqual(stringAfterReplace1, expectedResult)
    }

    // MARK: - Match
    func testMatchString() {
        let regex = try? Regex("[1-9]+")
        let firstMatchString = regex?.firstMatch(in: "abc5def")?.string
        XCTAssertEqual(firstMatchString, "5")
    }

    func testMatchRange() {
        let regex = try? Regex("[1-9]+")
        let firstMatchRange = regex?.firstMatch(in: "abc5def")?.range
        XCTAssertEqual(firstMatchRange?.lowerBound.encodedOffset, 3)
        XCTAssertEqual(firstMatchRange?.upperBound.encodedOffset, 4)
    }

    func testMatchCaptures() {
        let regex = try? Regex("([1-9])(Needed)(Optional)?")
        let match1 = regex?.firstMatch(in: "2Needed")
        let match2 = regex?.firstMatch(in: "5NeededOptional")

        enum CapturingError: Error { // swiftlint:disable:this nesting
            case indexTooHigh
            case noMatch
        }

        func captures(at index: Int, forMatch match: Regex.Match?) throws -> String? {
            guard let captures = match?.captures else { throw CapturingError.noMatch }
            guard captures.count > index else { throw CapturingError.indexTooHigh }
            return captures[index]
        }

        do {
            let match1Capture0 = try captures(at: 0, forMatch: match1)
            let match1Capture1 = try captures(at: 1, forMatch: match1)
            let match1Capture2 = try captures(at: 2, forMatch: match1)

            let match2Capture0 = try captures(at: 0, forMatch: match2)
            let match2Capture1 = try captures(at: 1, forMatch: match2)
            let match2Capture2 = try captures(at: 2, forMatch: match2)

            XCTAssertEqual(match1Capture0, "2")
            XCTAssertEqual(match1Capture1, "Needed")
            XCTAssertEqual(match1Capture2, nil)

            XCTAssertEqual(match2Capture0, "5")
            XCTAssertEqual(match2Capture1, "Needed")
            XCTAssertEqual(match2Capture2, "Optional")
        } catch let error as CapturingError {
            switch error {
            case .indexTooHigh:
                XCTFail("Capturing group index is too high.")

            case .noMatch:
                XCTFail("The match is nil.")
            }
        } catch {
            XCTFail("An unexpected error occured.")
        }
    }

    func testMatchStringApplyingTemplate() {
        let regex = try? Regex("([1-9])(Needed)")
        let match = regex?.firstMatch(in: "1Needed")
        XCTAssertEqual(match?.string(applyingTemplate: "Test$1ThatIs$2"), "Test1ThatIsNeeded")
    }

    // MARK: - Equatable
    func testEquatable() {
        do {
            let regex1 = try Regex("abc")
            let regex2 = try Regex("abc")
            let regex3 = try Regex("cba")
            let regex4 = try Regex("abc", options: [.ignoreCase])
            let regex5 = regex1

            XCTAssertEqual(regex1, regex2)
            XCTAssertNotEqual(regex1, regex3)
            XCTAssertNotEqual(regex1, regex4)
            XCTAssertEqual(regex1, regex5)

            XCTAssertNotEqual(regex2, regex3)
            XCTAssertNotEqual(regex2, regex4)
            XCTAssertEqual(regex2, regex5)

            XCTAssertNotEqual(regex3, regex4)
            XCTAssertNotEqual(regex3, regex5)

            XCTAssertNotEqual(regex4, regex5)
        } catch {
            XCTFail("Sample Regex creation failed.")
        }
    }

    // MARK: - CustomStringConvertible
    func testRegexCustomStringConvertible() {
        let regex = try? Regex("foo")
        XCTAssertEqual(regex?.description, "Regex<\"foo\">")
    }

    func testMatchCustomStringConvertible() {
        let regex = try? Regex("bar")
        let match = regex?.firstMatch(in: "bar")!
        XCTAssertEqual(match?.description, "Match<\"bar\">")
    }
}
