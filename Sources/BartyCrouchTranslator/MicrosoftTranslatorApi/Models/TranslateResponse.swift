import Foundation

struct TranslateResponse: Decodable {
  struct Translation: Decodable {
    let text: String
    let to: String
  }

  let translations: [Translation]
}
