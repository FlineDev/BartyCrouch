// Created by Cihat Gündüz on 06.11.18.

import Foundation

struct CodeOptions: Codable {
    let defaultToKeys: Bool
    let additive: Bool
    let customFunction: String?
    let customLocalizableName: String?
}
