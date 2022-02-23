import Foundation
import Toml

protocol TomlCodable {
  static func make(toml: Toml) throws -> Self
  func tomlContents() -> String
}
