// Created by Cihat Gündüz on 06.11.18.

import Foundation

struct TranslateOptions: Codable {
    enum API: String, Codable {
        case bing
        case google
    }

    let api: API
    let id: String?
    let secret: String?
}
