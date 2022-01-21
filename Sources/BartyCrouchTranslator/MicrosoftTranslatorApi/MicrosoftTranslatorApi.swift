import Foundation
import Microya

// Documentation can be found here: https://docs.microsoft.com/en-us/azure/cognitive-services/translator/reference/v3-0-translate

enum MicrosoftTranslatorApi {
  case translate(texts: [String], from: Language, to: [Language], microsoftSubscriptionKey: String)

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

extension MicrosoftTranslatorApi: Endpoint {
  typealias ClientErrorType = EmptyBodyResponse

  static var baseUrl: URL {
    return URL(string: "https://api.cognitive.microsofttranslator.com")!
  }

  var decoder: JSONDecoder {
    return JSONDecoder()
  }

  var encoder: JSONEncoder {
    return JSONEncoder()
  }

  var subpath: String {
    switch self {
    case .translate:
      return "/translate"
    }
  }

  var method: HttpMethod {
    switch self {
    case let .translate(texts, _, _, _):  // swiftlint:disable:next force_try
      return .post(body: try! encoder.encode(texts.map { TranslateRequest(Text: $0) }))
    }
  }

  var queryParameters: [String: QueryParameterValue] {
    var urlParameters: [String: QueryParameterValue] = ["api-version": "3.0"]

    switch self {
    case let .translate(_, sourceLanguage, targetLanguages, _):
      urlParameters["from"] = .string(sourceLanguage.rawValue)
      urlParameters["to"] = .array(targetLanguages.map { $0.rawValue })
    }

    return urlParameters
  }

  var headers: [String: String] {
    switch self {
    case let .translate(_, _, _, microsoftSubscriptionKey):
      return [
        "Ocp-Apim-Subscription-Key": microsoftSubscriptionKey,
        "Content-Type": "application/json",
      ]
    }
  }
}
