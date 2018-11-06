// Created by Cihat Gündüz on 06.11.18.

import Foundation

struct UpdateOptions: Codable {
    let interface: InterfacesOptions
    let code: CodeOptions
    let translate: TranslateOptions
    let normalize: NormalizeOptions
}
