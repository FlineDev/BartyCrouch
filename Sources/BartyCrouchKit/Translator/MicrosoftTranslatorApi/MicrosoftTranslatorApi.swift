//
//  MicrosoftTranslatorApi.swift
//  BartyCrouchKit
//
//  Created by Cihat Gündüz on 14.01.19.
//

import Foundation

// Documentation can be found here: https://docs.microsoft.com/en-us/azure/cognitive-services/translator/reference/v3-0-translate

enum MicrosoftTranslatorApi {
    case translate(from: Language, to: [Language], texts: [String])

    static let maximumTextsPerRequest: Int = 25
    static let maximumTextsLengthPerRequest: Int = 5_000
}

extension MicrosoftTranslatorApi: JsonApi {
    var decoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }

    var encoder: JSONEncoder {
        let jsonEncoder = JSONEncoder()
        return jsonEncoder
    }

    var baseUrl: URL {
        return URL(string: "https://api.cognitive.microsofttranslator.com")!
    }

    var path: String {
        switch self {
        case .translate:
            return "/translate"
        }
    }

    var method: Method {
        switch self {
        case .translate:
            return .post
        }
    }

    var urlParameters: [(key: String, value: String)] {
        var urlParameters: [(String, String)] = [(key: "api-version", value: "3.0")]

        switch self {
        case let .translate(sourceLanguage, targetLanguages, _):
            urlParameters.append((key: "from", value: sourceLanguage.rawValue))

            for targetLanguage in targetLanguages {
                urlParameters.append((key: "to", value: targetLanguage.rawValue))
            }
        }

        return urlParameters
    }

    var bodyData: Data? {
        switch self {
        case let .translate(_, _, texts):
            return try! encoder.encode(texts.map { TranslateRequest(Text: $0) })
        }
    }

    var headers: [String: String] {
        var headers: [String: String] = [
            "Ocp-Apim-Subscription-Key": Secrets.microsoftSubscriptionKey,
            "Content-Type": "application/json"
        ]

//        if let bodyData = bodyData {
//            headers["Content-Length"] = String(bodyData.count)
//        }

        return headers
    }
}
