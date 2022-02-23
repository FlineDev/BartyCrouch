//  Created by Frederick Pietschmann on 15.02.20.

import Foundation
import Toml

public extension Toml {
  func filePaths(_ path: String..., singularKey: String, pluralKey: String) -> [String] {
    return array(path + [pluralKey]) ?? string(path + [singularKey]).map { [$0] } ?? ["."]
  }
}
