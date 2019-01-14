//
//  MicrosoftTranslatorApiTests.swift
//  BartyCrouchKitTests
//
//  Created by Cihat Gündüz on 14.01.19.
//

@testable import BartyCrouchKit
import Foundation
import XCTest

class MicrosoftTranslatorApiTests: XCTestCase {
    func testTranslate() {
        let endpoint = MicrosoftTranslatorApi.translate(from: .english, to: [.german, .turkish], texts: ["How old are you?", "Love"])

        switch endpoint.request(type: [TranslateResponse].self) {
        case let .success(translateResponses):
            XCTAssertEqual(translateResponses[0].translations[0].to, "de")
            XCTAssertEqual(translateResponses[0].translations[0].text, "Wie alt sind Sie?")

            XCTAssertEqual(translateResponses[0].translations[1].to, "tr")
            XCTAssertEqual(translateResponses[0].translations[1].text, "Kaç yaşındasınız?")

            XCTAssertEqual(translateResponses[1].translations[0].to, "de")
            XCTAssertEqual(translateResponses[1].translations[0].text, "Liebe")

            XCTAssertEqual(translateResponses[1].translations[1].to, "tr")
            XCTAssertEqual(translateResponses[1].translations[1].text, "Aşk")

        case let .failure(failure):
            XCTFail(failure.localizedDescription)
        }
    }
}
