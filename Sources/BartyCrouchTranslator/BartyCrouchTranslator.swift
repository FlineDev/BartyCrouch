import Foundation
import Microya
import MungoHealer

/// Translator service to translate texts from one language to another.
///
/// NOTE: Currently only supports Microsoft Translator Text API using a subscription key.
public final class BartyCrouchTranslator {
  public typealias Translation = (language: Language, translatedText: String)

  /// The supported translation services.
  public enum TranslationService {
    /// The Microsoft Translator Text API.
    /// Website: https://docs.microsoft.com/en-us/azure/cognitive-services/translator/translator-info-overview
    ///
    /// - Parameters:
    ///   - subscriptionKey: The `Ocp-Apim-Subscription-Key`, also called "Azure secret key" in the docs.
    case microsoft(subscriptionKey: String)
    case deepL(apiKey: String)
  }

  private let microsoftProvider = ApiProvider<MicrosoftTranslatorApi>(baseUrl: MicrosoftTranslatorApi.baseUrl)
  private let deepLProvider: ApiProvider<DeepLApi>

  private let translationService: TranslationService

  /// Creates a new translator object configured to use the specified translation service.
  public init(
    translationService: TranslationService
  ) {
    self.translationService = translationService

    let deepLApiType: DeepLApi.ApiType
    if case let .deepL(apiKey) = translationService {
      deepLApiType = apiKey.hasSuffix(":fx") ? .free : .pro
    }
    else {
      deepLApiType = .pro
    }

    deepLProvider = ApiProvider<DeepLApi>(baseUrl: DeepLApi.baseUrl(for: deepLApiType))
  }

  /// Translates the given text from a given language to one or multiple given other languages.
  ///
  /// - Parameters:
  ///   - text: The text to be translated.
  ///   - sourceLanguage: The source language the given text is in.
  ///   - targetLanguages: An array of other languages to be translated to.
  /// - Returns: A `Result` wrapper containing an array of translations if the request was successful, else the related error.
  public func translate(
    text: String,
    from sourceLanguage: Language,
    to targetLanguages: [Language]
  ) -> Result<[Translation], MungoError> {
    switch translationService {
    case let .microsoft(subscriptionKey):
      let endpoint = MicrosoftTranslatorApi.translate(
        texts: [text],
        from: sourceLanguage,
        to: targetLanguages,
        microsoftSubscriptionKey: subscriptionKey
      )

      switch microsoftProvider.performRequestAndWait(on: endpoint, decodeBodyTo: [TranslateResponse].self) {
      case let .success(translateResponses):
        if let translations: [Translation] = translateResponses.first?.translations
          .map({ (Language.with(locale: $0.to)!, $0.text) })
        {
          return .success(translations)
        }
        else {
          return .failure(
            MungoError(source: .internalInconsistency, message: "Could not fetch translation(s) for '\(text)'.")
          )
        }

      case let .failure(failure):
        return .failure(MungoError(source: .internalInconsistency, message: failure.localizedDescription))
      }

    case let .deepL(apiKey):
      var allTranslations: [Translation] = []
      for targetLanguage in targetLanguages {
        let endpoint = DeepLApi.translate(texts: [text], from: sourceLanguage, to: targetLanguage, apiKey: apiKey)
        switch deepLProvider.performRequestAndWait(on: endpoint, decodeBodyTo: DeepLTranslateResponse.self) {
        case let .success(translateResponse):
          let translations: [Translation] = translateResponse.translations.map({ (targetLanguage, $0.text) })
          allTranslations.append(contentsOf: translations)

        case let .failure(failure):
          return .failure(MungoError(source: .internalInconsistency, message: failure.localizedDescription))
        }
      }

      return .success(allTranslations)
    }
  }
}
