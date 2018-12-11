import Foundation

public enum Language: String {
    case Arabic                 = "ar"
    case Bosnian                = "bs"
    case BosnianLatin           = "bs-Latn"
    case Bulgarian              = "bg"
    case Catalan                = "ca"
    case ChineseSimplified      = "zh-CHS"
    case ChineseTraditional     = "zh-CHT"
    case Croation               = "hr"
    case Czech                  = "cs"
    case Danish                 = "da"
    case Dutch                  = "nl"
    case English                = "en"
    case Estonian               = "et"
    case Finnish                = "fi"
    case French                 = "fr"
    case German                 = "de"
    case Greek                  = "el"
    case HaitianCreole          = "ht"
    case Hebrew                 = "he"
    case Hindi                  = "hi"
    case HmongDaw               = "mww"
    case Hungarian              = "hu"
    case Indonesian             = "id"
    case Italian                = "it"
    case Japanese               = "ja"
    case Kiswahili              = "sw"
    case Klingon                = "tlh"
    case KlingonPiqad           = "tlh-Qaak"
    case Korean                 = "ko"
    case Latvian                = "lv"
    case Lithuanian             = "lt"
    case Malay                  = "ms"
    case Maltese                = "mt"
    case Norwegian              = "no"
    case Persian                = "fa"
    case Polish                 = "pl"
    case Portuguese             = "pt"
    case QueretaroOtomi         = "otq"
    case Romanian               = "ro"
    case Russian                = "ru"
    case Serbian                = "sr"
    case SerbianCyrillic        = "sr-Cyrl"
    case SerbianLatin           = "sr-Latn"
    case Slovak                 = "sk"
    case Slovenian              = "sl"
    case Spanish                = "es"
    case Swedish                = "sv"
    case Thai                   = "th"
    case Turkish                = "tr"
    case Ukrainian              = "uk"
    case Urdu                   = "ur"
    case Vietnamese             = "vi"
    case Welsh                  = "cy"
    case YucatecMaya            = "yua"

    public static func languageForLocale(languageCode langCode: String, region: String?) -> Language? {
        if let region = region {
            switch (langCode, region) {
            case ("zh", "Hans"):
                return Language.ChineseSimplified
            case ("zh", "Hant"):
                return Language.ChineseTraditional
            default:
                if let language = Language(rawValue: "\(langCode)-\(region)") {
                    return language
                }
            }
        }

        switch langCode {
        case "nb":
            return Language.Norwegian
        default:
            return Language(rawValue: langCode)
        }
    }
}
