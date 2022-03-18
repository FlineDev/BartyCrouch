//  Created by Frederick Pietschmann on 15.02.20.

import Foundation

extension Array where Element: Hashable {
  func withoutDuplicates() -> Array {
    var seen = [Element: Bool]()
    return filter { seen.updateValue(true, forKey: $0) == nil }
  }
}
