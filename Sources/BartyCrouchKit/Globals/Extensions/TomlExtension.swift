//  Created by Frederick Pietschmann on 15.02.20.

import Foundation
import Toml

extension Toml {
    public func filePaths(_ path: String..., singularKey: String, pluralKey: String) -> [String] {
        return array(path + [pluralKey]) ?? string(path + [singularKey]).map { [$0] } ?? ["."]
    }
}
