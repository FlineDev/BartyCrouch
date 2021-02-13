import Foundation
import Microya

// Documentation can be found here: https://www.deepl.com/ja/docs-api/

enum DeeplApi {
    case translate(texts: [String], from: Language, to: Language, apiKey: String)

    static let maximumTextsPerRequest: Int = 25
    static let maximumTextsLengthPerRequest: Int = 5_000

    static func textBatches(forTexts texts: [String]) -> [[String]] {
        var batches: [[String]] = []
        var currentBatch: [String] = []
        var currentBatchTotalLength: Int = 0

        for text in texts {
            if currentBatch.count < maximumTextsPerRequest && text.count + currentBatchTotalLength < maximumTextsLengthPerRequest {
                currentBatch.append(text)
                currentBatchTotalLength += text.count
            } else {
                batches.append(currentBatch)

                currentBatch = [text]
                currentBatchTotalLength = text.count
            }
        }

        return batches
    }
}

extension DeeplApi: Endpoint {
    typealias ClientErrorType = DeeplTranslateErrorResponse

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var encoder: JSONEncoder {
        JSONEncoder()
    }

    var baseUrl: URL {
        URL(string: "https://api.deepl.com")!
    }

    var subpath: String {
        switch self {
        case .translate:
            return "/v2/translate"
        }
    }

    var method: HttpMethod {
        .get
    }

    var queryParameters: [String: QueryParameterValue] {
        var urlParameters: [String: QueryParameterValue] = [:]

        switch self {
        case let .translate(texts, sourceLanguage, targetLanguage, apiKey):
            urlParameters["text"] = .array(texts)
            urlParameters["source_lang"] = .string(sourceLanguage.rawValue.capitalized)
            urlParameters["target_lang"] = .string(targetLanguage.rawValue.capitalized)
            urlParameters["auth_key"] = .string(apiKey)
        }
        
        return urlParameters
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
