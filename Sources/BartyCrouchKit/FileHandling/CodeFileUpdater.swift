// Created by Cihat Gündüz on 23.01.19.

import Foundation

final class CodeFileUpdater {
    typealias TranslationElement = (langCode: String, translation: String)
    typealias TranslateEntry = (key: String, translations: [TranslationElement], comment: String?)

    private let path: String

    init(path: String) {
        self.path = path
    }

    func findTranslateEntries(typeName: String, translateMethodName: String) -> [TranslateEntry] {
        // TODO: not yet implemented
        return []
    }

    func transform(translateEntries: [TranslateEntry], using transformer: Transformer) {
        // TODO: not yet implemented
    }
}
