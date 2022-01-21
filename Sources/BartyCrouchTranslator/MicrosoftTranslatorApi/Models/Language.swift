import Foundation

/// The languages supported.
public enum Language: String {
  case afrikaans = "af"
  case arabic = "ar"
  case assamese = "as"
  case bangla = "bn"
  case bosnian = "bs"
  case bulgarian = "bg"
  case cantoneseTraditional = "yue"
  case catalan = "ca"
  case chineseSimplified = "zh-Hans"
  case chineseTraditional = "zh-Hant"
  case croatian = "hr"
  case czech = "cs"
  case dari = "prs"
  case danish = "da"
  case dutch = "nl"
  case english = "en"
  case estonian = "et"
  case fijian = "fj"
  case filipino = "fil"
  case finnish = "fi"
  case french = "fr"
  case frenchCanada = "fr-ca"
  case german = "de"
  case greek = "el"
  case gujarati = "gu"
  case haitianCreole = "ht"
  case hebrew = "he"
  case hindi = "hi"
  case hmongDaw = "mww"
  case hungarian = "hu"
  case icelandic = "is"
  case indonesian = "id"
  case irish = "ga"
  case italian = "it"
  case japanese = "ja"
  case kannada = "kn"
  case kazakh = "kk"
  case klingon = "tlh-Latn"
  case klingonPlqad = "tlh-Piqd"
  case korean = "ko"
  case kurdishCentral = "ku"
  case kurdishNorthern = "kmr"
  case latvian = "lv"
  case lithuanian = "lt"
  case malagasy = "mg"
  case malay = "ms"
  case malayalam = "ml"
  case maltese = "mt"
  case maori = "mi"
  case marathi = "mr"
  case norwegian = "nb"
  case odia = "or"
  case pashto = "ps"
  case persian = "fa"
  case polish = "pl"
  case portugueseBrazil = "pt"
  case portuguesePortugal = "pt-pt"
  case punjabi = "pa"
  case queretaroOtomi = "otq"
  case romanian = "ro"
  case russian = "ru"
  case samoan = "sm"
  case serbianCyrillic = "sr-Cyrl"
  case serbianLatin = "sr-Latn"
  case slovak = "sk"
  case slovenian = "sl"
  case spanish = "es"
  case swahili = "sw"
  case swedish = "sv"
  case tahitian = "ty"
  case tamil = "ta"
  case telugu = "te"
  case thai = "th"
  case tongan = "to"
  case turkish = "tr"
  case ukrainian = "uk"
  case urdu = "ur"
  case vietnamese = "vi"
  case welsh = "cy"
  case yucatecMaya = "yua"

  /// Returns the language object matching the given lang code & region.
  ///
  /// - Parameters:
  ///   - languageCode: The 2 or 3-letter language code. See list of languages in `Language` enum to check if yours is supported.
  ///   - region: The region code further specifying the language. See list of languages in `Language` enum to check if yours is supported.
  /// - Returns: The language object best matching your specified languageCode and region combination.
  public static func with(languageCode: String, region: String?) -> Language? {
    guard let region = region else { return Language(rawValue: languageCode) }
    return Language(rawValue: "\(languageCode)-\(region)")
      ?? Language(rawValue: "\(languageCode)-\(region.lowercased())")
      ?? Language(rawValue: "\(languageCode)-\(region.capitalized)")
      ?? Language(rawValue: languageCode)
  }

  /// Returns the language object matching the given lang code & region.
  ///
  /// - Parameters:
  ///   - languageCode: The 2 or 3-letter language code. See list of languages in `Language` enum to check if yours is supported.
  ///   - region: The region code further specifying the language. See list of languages in `Language` enum to check if yours is supported.
  /// - Returns: The language object best matching your specified languageCode and region combination.
  public static func with(locale: String) -> Language? {
    let separator: Character = "-"
    let components = locale.split(separator: separator)
    if components.count > 1 {
      return with(languageCode: String(components[0]), region: String(components[1]))
    }
    else {
      return with(languageCode: String(components[0]), region: nil)
    }
  }
}
