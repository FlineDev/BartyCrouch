//
//  BartyCrouch.swift
//  Demo
//
//  Created by Cihat Gündüz on 24.01.19.
//  Copyright © 2019 Flinesoft. All rights reserved.
//

import Foundation

enum BartyCrouch {
    enum SupportedLanguage: String {
        // TODO: remove unsupported languages from the following cases list & add any missing languages
        case arabic = "ar"
        case chineseSimplified = "zh-Hans"
        case chineseTraditional = "zh-Hant"
        case english = "en"
        case french = "fr"
        case german = "de"
        case hindi = "hi"
        case italian = "it"
        case japanese = "ja"
        case korean = "ko"
        case malay = "ms"
        case portuguese = "pt-BR"
        case russian = "ru"
        case spanish = "es"
        case turkish = "tr"
    }

    static func translate(key: String, translations: [SupportedLanguage: String], comment: String? = nil) -> String {
        let typeName = String(describing: BartyCrouch.self)
        let methodName = #function

        print(
            "Warning: [BartyCrouch]",
            "Untransformed \(typeName).\(methodName) method call found with key '\(key)' and base translations '\(translations)'.",
            "Please ensure that BartyCrouch is installed and configured correctly."
        )

        // fall back in case something goes wrong with BartyCrouch transformation
        return "BC: TRANSFORMATION FAILED!"
    }
}
