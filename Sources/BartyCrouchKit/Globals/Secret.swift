import Foundation

public enum Secret: Equatable {
    case microsoftTranslator(secret: String)
    case deepl(secret: String)
}
