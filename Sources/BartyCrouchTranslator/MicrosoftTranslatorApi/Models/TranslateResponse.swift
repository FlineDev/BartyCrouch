//  Created by Cihat Gündüz on 14.01.19.

import Foundation

struct TranslateResponse: Decodable {
    struct Translation: Decodable {
        let text: String
        let to: String
    }

    let translations: [Translation]
}
