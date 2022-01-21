import Foundation

extension String {
  var absolutePath: String {
    return URL(fileURLWithPath: self).path
  }

  func firstCharacterLowercased() -> String {
    let firstCharacter = prefix(1)
    let leftoverString = suffix(from: firstCharacter.endIndex)
    return firstCharacter.lowercased() + leftoverString
  }
}
