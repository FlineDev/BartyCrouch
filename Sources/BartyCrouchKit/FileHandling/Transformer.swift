// Created by Cihat Gündüz on 23.01.19.

import Foundation

enum Transformer: String, CaseIterable {
    case foundation
    case swiftgenStructured

    func transformedCode(key: String, translations: [String: String], comment: String?) -> String {
        switch self {
        case .foundation:
            return "NSLocalizedString(\"\(key)\", comment: \"\(comment ?? "")\")"

        case .swiftgenStructured:
            // e.g. the key could be something like 'ONBOARDING.FIRST_PAGE.HEADER_TITLE' or 'onboarding.first-page.header-title'
            let keywordSeparators: CharacterSet = CharacterSet(charactersIn: ".")
            let casingSeparators: CharacterSet = CharacterSet(charactersIn: "-_")

            // e.g. ["ONBOARDING", "FIRST_PAGE", "HEADER_TITLE"]
            let keywords: [String] = key.components(separatedBy: keywordSeparators)

            // e.g. [["ONBOARDING"], ["FIRST", "PAGE"], ["HEADER", "TITLE"]]
            let keywordsCasingComponents: [[String]] = keywords.map { $0.components(separatedBy: casingSeparators) }

            // e.g. ["Onboarding", "FirstPage", "HeaderTitle"]
            var swiftgenKeyComponents: [String] = keywordsCasingComponents.map { $0.map { $0.capitalized }.joined() }

            // e.g. ["Onboarding", "FirstPage", "headerTitle"]
            let lastKeyComponentIndex: Int = swiftgenKeyComponents.endIndex - 1
            swiftgenKeyComponents[lastKeyComponentIndex] = swiftgenKeyComponents[lastKeyComponentIndex].firstCharacterLowercased()

            // e.g. "Onboarding.FirstPage.headerTitle"
            let swiftgenL10nSuffix: String = swiftgenKeyComponents.joined(separator: ".")

            // e.g. "L10n.Onboarding.FirstPage.headerTitle"
            return "L10n.\(swiftgenL10nSuffix)"
        }
    }
}
