import Foundation

struct DeeplTranslateResponse: Decodable {
    struct Translation: Decodable {
        let detectedSourceLanguage: String
        let text: String
    }

    let translations: [Translation]
}
