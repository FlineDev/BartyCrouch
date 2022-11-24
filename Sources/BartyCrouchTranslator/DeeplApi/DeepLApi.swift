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
      let textEntries = texts.map { "text=\($0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)" }
        .joined(separator: "&")
      let authKeyEntry = "auth_key=\(authKey)"
      let sourceLanguageEntry = "source_lang=\(sourceLanguage.deepLParameterValue)"
      let targetLanguageEntry = "target_lang=\(targetLanguage.deepLParameterValue)"
      let bodyString = [authKeyEntry, sourceLanguageEntry, targetLanguageEntry, textEntries].joined(separator: "&")
      return .post(body: bodyString.data(using: .utf8)!)
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
