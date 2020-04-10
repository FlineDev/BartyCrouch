@testable import BartyCrouchTranslator
import Foundation
import XCTest

class MicrosoftTranslatorApiTests: XCTestCase {
    func testTranslate() {
        let microsoftSubscriptionKey = "" // TODO: load from environment variable
        guard !microsoftSubscriptionKey.isEmpty else { return }

        let endpoint = MicrosoftTranslatorApi.translate(
            texts: ["How old are you?", "Love"],
            from: .english,
            to: [.german, .turkish],
            microsoftSubscriptionKey: microsoftSubscriptionKey
        )

        switch endpoint.request(type: [TranslateResponse].self) {
        case let .success(translateResponses):
            XCTAssertEqual(translateResponses[0].translations[0].to, "de")
            XCTAssertEqual(translateResponses[0].translations[0].text, "Wie alt sind Sie?")

            XCTAssertEqual(translateResponses[0].translations[1].to, "tr")
            XCTAssertEqual(translateResponses[0].translations[1].text, "Kaç yaşındasınız?")

            XCTAssertEqual(translateResponses[1].translations[0].to, "de")
            XCTAssertEqual(translateResponses[1].translations[0].text.lowercased(), "Liebe".lowercased())

            XCTAssertEqual(translateResponses[1].translations[1].to, "tr")
            XCTAssertEqual(translateResponses[1].translations[1].text, "Aşk")

        case let .failure(failure):
            XCTFail(failure.localizedDescription)
        }
    }
}
