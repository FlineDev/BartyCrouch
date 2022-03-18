import Foundation

struct DeepLTranslateResponse: Decodable {
  struct Translation: Decodable {
    let detectedSourceLanguage: String
    let text: String
  }

  let translations: [Translation]
}
