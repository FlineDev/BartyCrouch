import Foundation
import Microya

// Documentation can be found here: https://www.deepl.com/ja/docs-api/

enum DeepLApi {
  case translate(texts: [String], from: Language, to: Language, apiKey: String)

  static let maximumTextsPerRequest: Int = 25
  static let maximumTextsLengthPerRequest: Int = 5_000

  static func textBatches(forTexts texts: [String]) -> [[String]] {
    var batches: [[String]] = []
    var currentBatch: [String] = []
    var currentBatchTotalLength: Int = 0

    for text in texts {
      if currentBatch.count < maximumTextsPerRequest
          && text.count + currentBatchTotalLength < maximumTextsLengthPerRequest
      {
        currentBatch.append(text)
        currentBatchTotalLength += text.count
      }
      else {
        batches.append(currentBatch)

        currentBatch = [text]
        currentBatchTotalLength = text.count
      }
    }

    return batches
  }
}

extension DeepLApi: Endpoint {
  typealias ClientErrorType = DeepLTranslateErrorResponse

  enum ApiType {
    case free
    case pro
  }

  var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }

  var subpath: String {
    switch self {
    case .translate:
      return "/v2/translate"
    }
  }

  var method: HttpMethod {
    switch self {
    case .translate(let texts, let sourceLanguage, let targetLanguage, let authKey):
      
      let authKeyItem = URLQueryItem(name: "auth_key", value: authKey)
      let textItem = URLQueryItem(name: "text", value: text)
      let targetLangItem = URLQueryItem(name: "target_lang", value: targetLanguage.deepLParameterValue)
      let sourceLangItem = URLQueryItem(name: "source_lang", value: sourceLang.deepLParameterValue)
      let formalityItem = URLQueryItem(name: "formality", value: "prefer_less")
      
      var components = URLComponents()
      components.queryItems = [authKeyItem, textItem, targetLangItem, sourceLangItem, formalityItem].compactMap { $0 }
      
      guard let queryItemsString = comp.string else {
          fatalError("Invalid arguments.")
      }
                
      return .post(body: queryItemsString.suffix(queryItemsString.count - 1).data(using: .utf8)!)      
    }
  }

  var headers: [String: String] {
    ["Content-Type": "application/x-www-form-urlencoded"]
  }

  static func baseUrl(for apiType: ApiType) -> URL {
    switch apiType {
    case .free:
      return URL(string: "https://api-free.deepl.com")!

    case .pro:
      return URL(string: "https://api.deepl.com")!
    }
  }
}

private extension Language {
  var deepLParameterValue: String {
    switch self {
    case .chineseSimplified:
      return "ZH"

    default:
      return rawValue.uppercased()
    }
  }
}
