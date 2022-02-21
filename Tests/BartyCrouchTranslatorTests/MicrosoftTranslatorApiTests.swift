@testable import BartyCrouchTranslator
import Foundation
import Microya
import XCTest

class MicrosoftTranslatorApiTests: XCTestCase {
  func testTranslate() {
    let microsoftSubscriptionKey = try! Secrets.load().microsoftSubscriptionKey  // swiftlint:disable:this force_try
    guard !microsoftSubscriptionKey.isEmpty else { return }

    let endpoint = MicrosoftTranslatorApi.translate(
      texts: ["How old are you?", "Love"],
      from: .english,
      to: [
        .german,
        .turkish,
        Language.with(languageCode: "pt", region: "BR")!,
        Language.with(languageCode: "pt", region: "PT")!,
        Language.with(languageCode: "fr", region: "CA")!,
      ],
      microsoftSubscriptionKey: microsoftSubscriptionKey
    )

    let apiProvider = ApiProvider<MicrosoftTranslatorApi>(baseUrl: MicrosoftTranslatorApi.baseUrl)

    switch apiProvider.performRequestAndWait(on: endpoint, decodeBodyTo: [TranslateResponse].self) {
    case let .success(translateResponses):
      XCTAssertEqual(translateResponses[0].translations[0].to, "de")
      XCTAssertEqual(translateResponses[0].translations[0].text, "Wie alt bist du?")

      XCTAssertEqual(translateResponses[0].translations[1].to, "tr")
      XCTAssertEqual(translateResponses[0].translations[1].text, "Kaç yaşındasınız?")

      XCTAssertEqual(translateResponses[0].translations[2].to, "pt")
      XCTAssertEqual(translateResponses[0].translations[2].text, "Quantos anos tem?")

      XCTAssertEqual(translateResponses[0].translations[3].to, "pt-PT")
      XCTAssertEqual(translateResponses[0].translations[3].text, "Quantos anos tens?")

      XCTAssertEqual(translateResponses[0].translations[4].to, "fr-CA")
      XCTAssertEqual(translateResponses[0].translations[4].text, "Quel âge avez-vous?")

      XCTAssertEqual(translateResponses[1].translations[0].to, "de")
      XCTAssertEqual(translateResponses[1].translations[0].text.lowercased(), "Liebe".lowercased())

      XCTAssertEqual(translateResponses[1].translations[1].to, "tr")
      XCTAssertEqual(translateResponses[1].translations[1].text, "Aşk")

      XCTAssertEqual(translateResponses[1].translations[2].to, "pt")
      XCTAssertEqual(translateResponses[1].translations[2].text, "Amor")

      XCTAssertEqual(translateResponses[1].translations[3].to, "pt-PT")
      XCTAssertEqual(translateResponses[1].translations[3].text, "O amor")

      XCTAssertEqual(translateResponses[1].translations[4].to, "fr-CA")
      XCTAssertEqual(translateResponses[1].translations[4].text, "L’amour")

    case let .failure(failure):
      XCTFail(failure.localizedDescription)
    }
  }
}
