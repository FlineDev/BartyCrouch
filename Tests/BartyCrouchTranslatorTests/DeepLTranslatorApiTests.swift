@testable import BartyCrouchTranslator
import Foundation
import Microya
import XCTest

class DeepLTranslatorApiTests: XCTestCase {
  func testTranslate() {
    let apiKey = try! Secrets.load().deepLApiKey  // swiftlint:disable:this force_try
    guard !apiKey.isEmpty else { return }

    let endpoint = DeepLApi.translate(
      texts: ["How old are you?", "Love"],
      from: .english,
      to: .german,
      apiKey: apiKey
    )

    let apiProvider = ApiProvider<DeepLApi>(baseUrl: DeepLApi.baseUrl(for: .free))

    switch apiProvider.performRequestAndWait(on: endpoint, decodeBodyTo: DeepLTranslateResponse.self) {
    case let .success(translateResponses):
      XCTAssertEqual(translateResponses.translations[0].text, "Wie alt sind Sie?")

    case let .failure(failure):
      XCTFail(failure.localizedDescription)
    }
  }
}
